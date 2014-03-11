#encoding: utf-8
class PublishQuestionPackage < ActiveRecord::Base
  attr_protected :authentications
  belongs_to :teacher
  belongs_to :question_package
  has_one :task_message
  STATUS = {:NEW => 0, :FINISH => 1,:EXPIRED => 2}
  STATUS_NAME = {0 => "新任务", 1 => "完成",2 => '过期'}
  PER_PAGE = 10
  IS_CALC = {:WAIT => 0, :DEADL => 1}

  #获取当日或历史任务
  def self.get_tasks school_class_id, student_id, order_name=nil, date=nil, today_newer_id=nil
    my_tag_ids = Tag.get_my_tag_ids school_class_id, student_id
    tags = "#{my_tag_ids}".gsub(/\[/,"(").gsub(/\]/,")") if my_tag_ids && my_tag_ids.length != 0
    tasks_sql = "select p.id, q.name,p.question_package_id que_pack_id,p.start_time,p.end_time,
            p.question_packages_url FROM publish_question_packages p left join question_packages q
            on p.question_package_id = q.id where p.school_class_id = #{school_class_id}"
    date_now = Time.now.strftime('%Y-%m-%d')
    if !order_name.nil? && order_name == "first"
      tasks_sql += " and p.status = #{PublishQuestionPackage::STATUS[:NEW]} and
        p.start_time >= '#{date_now} 00:00:00'
        and p.start_time <= '#{date_now} 23:59:59'"
    end
    if !date.nil?
      tasks_sql += " and p.start_time >= '#{date} 00:00:00'
        and p.start_time <= '#{date} 23:59:59'"
    end
    tasks_sql += " and (p.tag_id is null or p.tag_id in #{tags})"  if my_tag_ids && my_tag_ids.length != 0
    tasks_sql += " and p.id != #{today_newer_id}" if !today_newer_id.nil?
    tasks_sql += " order by p.start_time desc"
    tasks_sql += " limit 1" if !order_name.nil? && order_name == "first"
    pub_tasks = PublishQuestionPackage.find_by_sql tasks_sql
    pub_tasks = pub_tasks[1..pub_tasks.length-1] if order_name.nil? && date.nil?
    pub_ids = pub_tasks.map(&:id)
    que_pack_ids = pub_tasks.map(&:que_pack_id)
    student_answer_records = StudentAnswerRecord.get_student_answer_status school_class_id,student_id, pub_ids
    student_answer_records = student_answer_records.group_by{ |sar| sar.pub_id }
    que_packs_types =  QuestionPackage.get_all_packs_que_types school_class_id, que_pack_ids
    que_packs_types = que_packs_types.group_by{ |q| q.id }
    tasks = []
    pub_tasks.each_with_index do |task|
      question_types = []
      finish_types = []
      if !que_packs_types[task.que_pack_id].nil?
        question_types = que_packs_types[task.que_pack_id].map(&:types)
      end
      if !student_answer_records[task.id].nil?
        finish_types = student_answer_records[task.id].map(&:types)
      end
      tasks << {:id => task.id, :name => task.name, :start_time => task.start_time,
                :question_types => question_types, :finish_types => finish_types,
                :end_time => task.end_time, :question_packages_url => task.question_packages_url
      }
    end
    tasks
  end

  #更新得分和成就
  def self.update_scores_and_achirvements answer_json, student, school_class, publish_question_package, student_answer_record

      #p answer_json
    if publish_question_package.id == answer_json["pub_id"].to_i
      #更新任务的完成状态
      if answer_json["status"].present?
        student_answer_record.update_attributes(:status => answer_json["status"].to_i)
      end

      #记录道具使用记录及更新道具数量
      if !answer_json["props"].nil?
        props = Prop.get_prop_num school_class.id, student.id
        props_types = props.map{|e| e[:types]}
        props = props.group_by {|e| e[:types]}
        answer_json["props"].each do |prop|
          if props_types.include? prop["types"].to_i
            user_prop_relation = UserPropRelation
                  .find_by_id props[prop["types"].to_i][0][:user_prop_relation_id]
            prop["branch_id"].each do |branch_id|
              if user_prop_relation
                r = RecordUseProp.create(:user_prop_relation_id => user_prop_relation.id,
                                     :branch_question_id => branch_id)
              end
            end
          end
          if prop["branch_id"] && prop["branch_id"].length != 0
            user_prop_relation.update_attributes(:user_prop_num =>
                    (user_prop_relation.user_prop_num-prop["branch_id"].length).to_i)
          end
        end
      end

      #查询题包下所有题型及各个题型的规定时间
      sql_str = "select q.types, sum(questions_time) time from questions q
          where question_package_id = #{publish_question_package.question_package.id} group by types"
      quetsions_time = Question.find_by_sql(sql_str)
      quetsions_time.each do |question|
        answer_details = answer_json[Question::TYPES_TITLE[question.types.to_i]]
        if answer_details.present?
          p answer_details
          types = Question::RECORD_TYPES[Question::TYPES_TITLE[question.types.to_i]]
          status = answer_details["status"].to_i
          update_time = answer_details["update_time"]
          use_time = answer_details["use_time"]
          score = 0
          if [2,3,4,5,6].include? types
            knowledges_cards_types = KnowledgesCard::MISTAKE_TYPES[:SELEST]  #选错
          elsif types == 0
            knowledges_cards_types = KnowledgesCard::MISTAKE_TYPES[:WRITE]   #拼错
          elsif types == 1
            knowledges_cards_types = KnowledgesCard::MISTAKE_TYPES[:READ]    #读错
          end
          card_bag = CardBag.find_by_student_id_and_school_class_id(student.id,
                                  school_class.id)

          if card_bag.nil?
            card_bag = CardBag.create(:student_id => student.id, :school_class_id => school_class.id)
          end
          ratios_count = 0
          answer_details["questions"].each do |question|
            ratios = question["branch_questions"].map {|e| [e["id"].to_i, e["ratio"].to_i, e["answer"].to_s]}
            ratios.each do |ratio|
              score += ratio[1]
              ratios_count += 1
              if ratio[1] < 100 && ratio[2].gsub(" ","").size != 0              #插入知识卡片
                card_bag.knowledges_cards.create(:mistake_types => knowledges_cards_types,
                                    :branch_question_id => ratio[0], :your_answer => ratio[2])
              end
            end
          end
          average_ratio = score/ratios_count <= 0 ? 0 : score/ratios_count

          record_details = RecordDetail
                .find_by_question_types_and_student_answer_record_id(types,
                                          student_answer_record.id)
          if record_details.nil?
            record_details = RecordDetail.create(:question_types => types,
                :student_answer_record_id => student_answer_record.id,
                :score => score, :is_complete => status, :used_time => use_time,
                :correct_rate => average_ratio, :specified_time => question.time)
          else
            record_details.update_attributes(:score => score, :is_complete => status,
                               :specified_time => question.time, :used_time => use_time,
                               :correct_rate => average_ratio)
          end

          #计算成就
          if status = answer_details["status"].to_i == 1
            time = ((DateTime.parse(publish_question_package.end_time
                                    .strftime("%Y-%m-%d %H:%M:%S")) - DateTime.parse(update_time)) *24 * 60).to_i
            if time > 0
              if average_ratio >= 60 && average_ratio <= 100
                ArchivementsRecord.update_archivements student, school_class, ArchivementsRecord::TYPES[:QUICKLY]
                if time > 120
                  ArchivementsRecord.update_archivements student, school_class, ArchivementsRecord::TYPES[:EARLY]
                end
              end
              if average_ratio == 100
                ArchivementsRecord.update_archivements student, school_class, ArchivementsRecord::TYPES[:ACCURATE]
              end
            end
          end
        else
          break
        end
      end
    end
  end
end


