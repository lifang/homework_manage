#encoding: utf-8
include StatisticsHelper
class PublishQuestionPackage < ActiveRecord::Base
  attr_protected :authentications
  belongs_to :teacher
  belongs_to :question_package
  has_one :task_message
  STATUS = {:NEW => 0, :FINISH => 1, :EXPIRED => 2}
  STATUS_NAME = {0 => "新任务", 1 => "完成", 2 => '过期'}
  PER_PAGE = 10
  IS_CALC = {:WAIT => 0, :DEADL => 1}
  TIME_TOW_HOUR = 120
  CORRECT_RATE_SIX = 60
  CORRECT_RATE_TEN = 100

  #获取当日或历史任务
  def self.get_tasks school_class_id, student_id, order_name=nil, date=nil, today_newer_id=nil
    my_tag_ids = Tag.get_my_tag_ids school_class_id, student_id
    my_tag_ids.delete(nil)
    tags = "#{my_tag_ids}".gsub(/\[/, "(").gsub(/\]/, ")") if my_tag_ids && my_tag_ids.length != 0
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
    tasks_sql += " and (p.tag_id is null or p.tag_id in #{tags})" if my_tag_ids && my_tag_ids.length != 0
    tasks_sql += " and p.id != #{today_newer_id}" if !today_newer_id.nil?
    tasks_sql += " order by p.start_time desc"
    tasks_sql += " limit 1" if !order_name.nil? && order_name == "first"
    pub_tasks = PublishQuestionPackage.find_by_sql tasks_sql
    pub_tasks = pub_tasks[1..pub_tasks.length-1] if order_name.nil? && date.nil?
    pub_ids = pub_tasks.present? ? pub_tasks.map(&:id) : []
    que_pack_ids = pub_tasks.present? ? pub_tasks.map(&:que_pack_id) : []
    s_a_rs = StudentAnswerRecord
    .select("publish_question_package_id id, answer_file_url")
    .where(["publish_question_package_id in (?) and student_id = ?", pub_ids, student_id])
    s_a_rs = s_a_rs.group_by {|s| s.id}
    s_a_r_status = StudentAnswerRecord.get_student_answer_status school_class_id, student_id, pub_ids
    s_a_r_status = s_a_r_status.group_by { |sar| sar.pub_id }
    que_packs_types = QuestionPackage.get_all_packs_que_types school_class_id, que_pack_ids
    que_packs_types = que_packs_types.group_by { |q| q.id }
    tasks = []
    if pub_tasks.present?
      pub_tasks.each_with_index do |task|
        question_types = []
        finish_types = []
        answer_url = nil
        if !que_packs_types[task.que_pack_id].nil?
          question_types = que_packs_types[task.que_pack_id].map(&:types)
        end
        if !s_a_r_status[task.id].nil?
          finish_types = s_a_r_status[task.id].map(&:types)
        end
        if !s_a_rs[task.id].nil?
          answer_url = s_a_rs[task.id][0][:answer_file_url]
        end
        tasks << {:id => task.id, :name => task.name, :start_time => task.start_time,
          :question_types => question_types, :finish_types => finish_types, :answer_url => answer_url,
          :end_time => task.end_time, :question_packages_url => task.question_packages_url
        }
      end
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
        props_types = props.map { |e| e[:types] }
        props = props.group_by { |e| e[:types] }
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
            if prop["branch_id"] && prop["branch_id"].length != 0
              if user_prop_relation
                user_prop_relation.update_attributes(:user_prop_num =>
                    (user_prop_relation.user_prop_num-prop["branch_id"].length).to_i)
              end  
            end
          end
        end
      end

      #查询题包下所有题型及各个题型的规定时间
      sql_str = "select q.types, sum(questions_time) time from questions q
          where question_package_id = #{publish_question_package.question_package.id} group by types"
      quetsions_time = Question.find_by_sql(sql_str)
      card_bag = CardBag.find_by_student_id_and_school_class_id(student.id,
        school_class.id)
      if card_bag.nil?
        card_bag = CardBag.create(:student_id => student.id, :school_class_id => school_class.id)
      end
      correct_rate_sum = []
      complete_rate_sum = []
      quetsions_time.each do |question|
        answer_details = answer_json[Question::TYPES_TITLE[question.types.to_i]]
        if answer_details.present?
          types = question.types.to_i
          record_details = RecordDetail
          .find_by_question_types_and_student_answer_record_id(types,
            student_answer_record.id)
          if record_details.nil? || record_details.is_complete != RecordDetail::IS_COMPLETE[:FINISH]
            status = answer_details["status"].to_i
            update_time = answer_details["update_time"]
            use_time = answer_details["use_time"]
            score = 0
            if [Question::TYPES[:TIME_LIMIT], Question::TYPES[:SELECTING], Question::TYPES[:LINING], Question::TYPES[:CLOZE], Question::TYPES[:SORT]].include? types
              knowledges_cards_types = KnowledgesCard::MISTAKE_TYPES[:SELEST] #选错
            elsif types == Question::TYPES[:LISTENING]
              knowledges_cards_types = KnowledgesCard::MISTAKE_TYPES[:WRITE] #拼错
            elsif types == Question::TYPES[:READING]
              knowledges_cards_types = KnowledgesCard::MISTAKE_TYPES[:READ] #读错
            end
            
            #获取某一提包的所有小题（5line）
            the_branch_questions_by_card_bag_id = KnowledgesCard.where("card_bag_id = ?" , card_bag.id )
            the_branch_question_ids = []
            if the_branch_questions_by_card_bag_id.present?
              the_branch_question_ids = the_branch_questions_by_card_bag_id.map(&:branch_question_id)
            end
            ratios_count = 0
            answer_details["questions"].each do |question|
              ratios = question["branch_questions"].map { |e| [e["id"].to_i, e["ratio"].to_i, e["answer"].to_s] }
              ratios.each do |ratio|
                score += ratio[1]
                ratios_count += 1
                if ratio[1] < CORRECT_RATE_TEN && ratio[2].gsub(" ", "").size != 0 #插入知识卡片
                  unless the_branch_question_ids.include?(ratio[0])  #判断是否有该题
                    card_bag.knowledges_cards.create(:mistake_types => knowledges_cards_types,
                      :branch_question_id => ratio[0],
                      :your_answer => ratio[2])
                  end
                end
              end
            end
            average_ratio=0
            average_ratio = score/ratios_count <= 0 ? 0 : score/ratios_count if ratios_count!=0
            #计算成就
            if status = answer_details["status"].to_i ==  PublishQuestionPackage::STATUS[:FINISH]
              time = ((DateTime.parse(publish_question_package.end_time
                    .strftime("%Y-%m-%d %H:%M:%S")) - DateTime.parse(update_time)) *24 * 60).to_i
              if record_details.nil?
                record_details = RecordDetail.create(:question_types => types,
                  :student_answer_record_id => student_answer_record.id,
                  :score => score, :is_complete => status, :used_time => use_time,
                  :correct_rate => average_ratio, :specified_time => question.time)
                update_archivements time,average_ratio,student,school_class,use_time,question
                #              else
                #                unless record_details.is_complete == RecordDetail::IS_COMPLETE[:FINISH]
                #                  record_details.update_attributes(:score => score, :is_complete => status,
                #                    :specified_time => question.time, :used_time => use_time,
                #                    :correct_rate => average_ratio)
                #                  update_archivements time,average_ratio,student,school_class,use_time,question
                #                end
              end
            end
          end
          unless record_details.nil?
            correct_rate_sum << record_details.correct_rate
            complete_rate_sum << record_details.is_complete
          end
        else
          break
        end
        
      end
      #计算平均正确率和平均完成率
      temp_sum = 0
      correct_rate_sum.each{|x| temp_sum+=x}
      average_correct_rate =  temp_sum/correct_rate_sum.length if correct_rate_sum.length != 0
      temp_sum=0
      complete_rate_sum.each{|x| temp_sum+=x if x==RecordDetail::IS_COMPLETE[:FINISH]}
      average_complete_rate =  temp_sum*100/complete_rate_sum.length if correct_rate_sum.length != 0
      student_answer_record.update_attributes(:average_correct_rate=>average_correct_rate||0,
        :average_complete_rate=> average_complete_rate||0 )
    end
  end

  def self.update_archivements time,average_ratio,student,school_class,use_time,question
    use_time = use_time.to_i
    if time > 0
      if average_ratio >= CORRECT_RATE_SIX && average_ratio <= CORRECT_RATE_TEN && use_time < question.time
        ArchivementsRecord.update_archivements student, school_class, ArchivementsRecord::TYPES[:QUICKLY]
        if time > TIME_TOW_HOUR
          ArchivementsRecord.update_archivements student, school_class, ArchivementsRecord::TYPES[:EARLY]
        end
      end
      if average_ratio == CORRECT_RATE_TEN
        ArchivementsRecord.update_archivements student, school_class, ArchivementsRecord::TYPES[:ACCURATE]
      end
    end
  end
  

  def self.get_homework_statistics date, school_class
    all_tags = nil
    current_task = nil
    question_types = nil
    details = nil
    average_correct_rate = 0
    average_complete_rate = 0
    today_tasks = PublishQuestionPackage
    .joins('left join tags t on publish_question_packages.tag_id = t.id')
    .select("publish_question_packages.id, publish_question_packages.tag_id,
              publish_question_packages.created_at,
              publish_question_packages.question_package_id, t.name")
    .where("publish_question_packages.created_at >= '#{date} 00:00:00'
             and publish_question_packages.created_at <= '#{date} 23:59:59'")
    .order("publish_question_packages.created_at desc")
    today_tasks = today_tasks.group_by {|t| t.tag_id } if today_tasks && today_tasks.present?
    
    all_tag_id = []
    tasks = []
    today_tasks.each do |tag_id, task|
      all_tag_id << tag_id
      tasks << task.first
    end  
    if tasks && tasks.length > 0
      task = tasks.first
      tags = Tag.where("id in (?)", all_tag_id)
      tags = tags.group_by {|t| t.id } if tags
      all_tags = []
      tasks.each do |task|
        if task.tag_id == 0
          all_tags << {:pub_id => task.id, :tag_name => "全班"}
        else  
          all_tags << {:pub_id => task.id, :tag_name => tags[task.tag_id].first.name}
        end  
      end  
      if task.present?
        info = PublishQuestionPackage.get_record_details task, school_class.id
        question_types = info[:question_types]
        students = info[:students]
        record_details = info[:record_details]
        student_answer_records = info[:student_answer_records]
        p student_answer_records
        average_correct_rate = info[:average_correct_rate]
        average_complete_rate = info[:average_complete_rate]
      end
    end

    {:all_tags => all_tags, :current_task => task, :question_types => question_types, :students => students,
     :average_correct_rate => average_correct_rate, :student_answer_records => student_answer_records, 
     :record_details =>record_details, :average_complete_rate => average_complete_rate}
  end

  #获取一个任务的答题信息
  def self.get_record_details task, school_class_id
    question_types = []
    student_answer_records = nil
    record_details = nil
    average_correct_rate = 0
    average_complete_rate = 0
    question_types = QuestionPackage.get_one_package_questions task.question_package_id
    question_types.map!(&:types)
    question_types.sort! if question_types.present?
    if task.tag_id == 0
      students_id = SchoolClassStudentRalastion.where(["school_class_id = ?",
          school_class_id]).map(&:student_id)
    else
      students_id = SchoolClassStudentRalastion.where(["school_class_id = ? and tag_id = ?", 
          school_class_id, task.tag_id]).map(&:student_id)
    end
    students = Student.select("students.id, u.name, u.avatar_url")
                      .joins("left join users u on students.user_id = u.id")
                      .where(["students.id in (?)", students_id])
    student_answer_records = StudentAnswerRecord
              .select("student_answer_records.id, student_answer_records.publish_question_package_id,
                  student_answer_records.average_correct_rate, student_answer_records.average_complete_rate,
                  student_answer_records.student_id")
              .where("publish_question_package_id = ? and student_id in (?)", task.id, students_id)
    average_value = StudentAnswerRecord
              .select("ifnull(avg(average_correct_rate),0) average_correct_rate, 
                      ifnull(avg(average_complete_rate),0) average_complete_rate")
              .where(["publish_question_package_id = ? and student_id in (?)", task.id, students_id]) 
    average_correct_rate = average_value.first.average_correct_rate
    average_complete_rate = average_value.first.average_complete_rate  
    if student_answer_records && student_answer_records.length > 0
      average_value = StudentAnswerRecord
                        .select("ifnull(avg(average_correct_rate),0) average_correct_rate, 
                                ifnull(avg(average_complete_rate),0) average_complete_rate")
                        .where(["publish_question_package_id = ? and student_id in (?)", task.id, students_id]) 
      student_answer_records_id = student_answer_records.map(&:id)
      record_details = RecordDetail.where(["student_answer_record_id in (?)",student_answer_records_id]) 
      record_details = record_details.group_by {|rd| rd.student_answer_record_id} if record_details && record_details.present?
      record_details.each do |student_answer_record_id, record_detail|
        rd_group_types = record_detail.group_by { |rd| rd.question_types } 
        record_details[student_answer_record_id] = rd_group_types
      end    
    end
    student_answer_records = student_answer_records.group_by {|s| s.student_id } if student_answer_records.present?
    {:question_types => question_types, :students => students,:student_answer_records => student_answer_records,
      :record_details => record_details, :average_correct_rate => average_correct_rate, 
      :average_complete_rate => average_complete_rate}
  end

 
  #按题型获取统计
  def self.get_quetion_types_statistics publish_question_package, tag_id, school_class_id
    question_types = []
    question_details = []
    sql = "school_class_id = ?"
    question_types = QuestionPackage.get_one_package_questions publish_question_package.question_package_id
    questions = question_types.map{|q| {:id => q.id, :types => q.types } }.uniq
    p question_types
    question_types.map!(&:types).uniq!
    question_types.sort! unless question_types.nil?
    params_sql = [sql, school_class_id]
    if tag_id.present?
      params_sql[0] += "and tag_id = ?"
      params_sql << tag_id.to_i
    end
    students_id = SchoolClassStudentRalastion.where(params_sql).select("student_id")
    students_id.map!(&:student_id).sort!
    if students_id && students_id.length > 0
      sql_str ="student_answer_records.publish_question_package_id = ? and
                student_answer_records.student_id in (?)
                and rd.id is not null and rd.is_complete = #{RecordDetail::IS_COMPLETE[:FINISH]}"
      student_answer_records = StudentAnswerRecord
      .joins("left join record_details rd on
                student_answer_records.id = rd.student_answer_record_id")
      .select("student_answer_records.id, student_answer_records.student_id,
                student_answer_records.answer_file_url, rd.question_types types")
      .where([sql_str, publish_question_package.id, students_id])
      #answer_urls = student_answer_records.map{|sar| }.uniq
      base_url = "#{Rails.root}/public"
      student_answer_records.map! do |sar|
        answer_records = {}
        answer_json = ""

        file_url = "#{base_url}#{sar.answer_file_url}"
        if sar.answer_file_url.present? && File.exist?(file_url)
          File.open(file_url) do |file|
            file.each do |line|
              answer_json += line.to_s
            end
          end
        end
        begin
          answer_records = ActiveSupport::JSON.decode(answer_json)
        rescue
          {:question_types => nil, :question_details => nil}
        end
        {:sar_id => sar.id, :student_id => sar.student_id,
          :answers => answer_records, :types => sar.types}
      end
      student_answer_records.map!{|s| {:student_id =>s[:student_id],  :answers => s[:answers]} }.uniq!
      questions = questions.group_by {|q| q[:types]}
      all_answers = []
      use_times = []
      if student_answer_records.present?
        student_answer_records.each do |sar|
          student_id = sar[:student_id]
          question_types.each do |types|
            #p Question::TYPE_NAME_ARR[types.to_i]
            if sar.present?
              if sar[:answers][Question::TYPE_NAME_ARR[types.to_i]].present? &&
                  sar[:answers][Question::TYPE_NAME_ARR[types.to_i]]["status"] ==
                  "#{RecordDetail::IS_COMPLETE[:FINISH]}"
                use_t = sar[:answers][Question::TYPE_NAME_ARR[types.to_i]]["use_time"].to_i
                use_times  << {:use_time => use_t, :types => types, :student_id => sar[:student_id]}
                if sar[:answers][Question::TYPE_NAME_ARR[types.to_i]]["questions"].present?
                  answers = sar[:answers][Question::TYPE_NAME_ARR[types.to_i]]["questions"]
                  .group_by{|q| q["id"]}
                  ques_id = questions[types.to_i].map{|q| q[:id]}
                  if ques_id.present?
                    ques_id.each do |que_id|
                      if answers["#{que_id}"].present?
                        correct_rate = -1
                        if answers["#{que_id}"][0]["branch_questions"].present?
                          correct_rate = calculate_every_question_correct_rate answers["#{que_id}"][0]["branch_questions"], types.to_i
                        end
                        all_answers << {:correct_rate => correct_rate,:question_id => que_id,
                          :students_id => sar[:student_id], :types => types.to_i}
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
    use_times = use_times.uniq if use_times.present?
    all_answers_group_types = all_answers.group_by{|q| q[:types]}

    all_answers_group_question_id = all_answers.group_by{|q| q[:question_id]}
    type_average_correct_rate = []
    question_types.each do |type|
      average_correct_rate = 0
      types_correct_rates = all_answers_group_types[type.to_i].map{|a| a[:correct_rate]} if all_answers_group_types[type.to_i].present?
      average_correct_rate = (eval types_correct_rates.join('+'))/types_correct_rates.length if types_correct_rates.present?
      type_average_correct_rate << {:average_correct_rate => average_correct_rate, :types =>type}
    end
    question_types.each do |type|
      questions[type].each do |question|
        question[:average_correct_rate] = -1
        current_ques = all_answers_group_question_id[question[:id]].map{|q| q[:correct_rate]} if all_answers_group_question_id[question[:id]].present?
        question[:average_correct_rate] = (eval current_ques.join('+'))/current_ques.length if current_ques.present?
      end
    end
    {:question_types => question_types, :questions => questions, :use_times => use_times, :type_average_correct_rate=>type_average_correct_rate}
  end
  
  
end


