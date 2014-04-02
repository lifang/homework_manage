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
    p my_tag_ids
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
    if my_tag_ids.present?
      tasks_sql += " and (p.tag_id = 0 or p.tag_id in #{tags})" 
    else
      tasks_sql += " and p.tag_id = 0"
    end
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
      average_complete_rate =  temp_sum*100/quetsions_time.length if quetsions_time.length != 0
      student_answer_record.update_attributes(:average_correct_rate=>average_correct_rate||0,
        :average_complete_rate=> average_complete_rate||0 )
    end
  end

  def self.update_archivements time,average_ratio,student,school_class,use_time,question
    use_time = use_time.to_i
    if time > 0
      if average_ratio >= CORRECT_RATE_SIX && average_ratio <= CORRECT_RATE_TEN && use_time < question.time
        ArchivementsRecord.update_archivements student, school_class, ArchivementsRecord::TYPES[:QUICKLY]
        add_prop_get_archivement student.id,Prop::TYPES[:Reduce_time],school_class
        if time > TIME_TOW_HOUR
          ArchivementsRecord.update_archivements student, school_class, ArchivementsRecord::TYPES[:EARLY]
        end
      end
      if average_ratio == CORRECT_RATE_TEN
        ArchivementsRecord.update_archivements student, school_class, ArchivementsRecord::TYPES[:ACCURATE]
        add_prop_get_archivement student.id,Prop::TYPES[:Show_corret_answer],school_class
      end
    end
  end
  #获得成就时加道具
  def self.add_prop_get_archivement student_id,prop_types,school_class
    student_prop = UserPropRelation.
      find_by_student_id_and_prop_id_and_school_class_id(student_id,prop_types,school_class.id)
    if student_prop
      student_prop.update_attribute(:user_prop_num,student_prop.user_prop_num+2);
    else
      UserPropRelation.create(student_id:student_id,
        user_prop_num:2,
        school_class_id:school_class.id,
        prop_id:prop_types)
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
              publish_question_packages.question_package_id, t.name tag_name")
    .where("publish_question_packages.created_at >= '#{date} 00:00:00'
             and publish_question_packages.created_at <= '#{date} 23:59:59'
          and publish_question_packages.school_class_id = #{school_class.id}")
    .order("publish_question_packages.created_at desc")
    today_tasks = today_tasks.group_by {|t| t.tag_id } if today_tasks && today_tasks.present? 
      all_tags = []
      if today_tasks.any?
        task = nil
        today_tasks.each do |tag_id, t|
  
          task = t.first
          if tag_id == 0
            all_tags << {:pub_id => t.first.id, :tag_name => "全班"}
          else  
            all_tags << {:pub_id => t.first.id, :tag_name => t.first.tag_name}
          end
        end 
        info = PublishQuestionPackage.get_record_details task, school_class.id
        question_types = info[:question_types]
        p question_types
        students = info[:students]
        record_details = info[:record_details]
        student_answer_records = info[:student_answer_records]
        average_correct_rate = info[:average_correct_rate]
        average_complete_rate = info[:average_complete_rate]
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
    que_types = QuestionPackage.get_one_package_questions task.question_package_id
    que_types = que_types.map(&:types).uniq.sort if que_types.present?
  
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
      p que_types
    student_answer_records = student_answer_records.group_by {|s| s.student_id } if student_answer_records.present?
    {:question_types => que_types, :students => students,:student_answer_records => student_answer_records,
      :record_details => record_details, :average_correct_rate => average_correct_rate, 
      :average_complete_rate => average_complete_rate}
  end
  
   #按题型获取统计
  def self.get_quetion_types_statistics publish_question_package, school_class_id
    # question_types
    # students_id
    # student_answer_records
    # record_details
    questions = []
    question_types = []
    use_times = []
    questions_answers = []
    questions = QuestionPackage.get_one_package_questions publish_question_package.question_package_id
    question_types = questions.map(&:types).uniq.sort if questions.present?
    p question_types
    questions = questions.group_by{ |q| q.types } if questions.present?
    if publish_question_package.tag_id == 0
      students = SchoolClassStudentRalastion.where(["school_class_id = ?",school_class_id])
                                            .select("student_id").uniq
    else
      students = SchoolClassStudentRalastion.where(["school_class_id = ? and tag_id in (?)",
                                                  school_class_id,  publish_question_package.tag_id])   
                                            .select("student_id").uniq
    end  
    if students.any?
      students_id = students.map(&:student_id)
      student_answer_records = StudentAnswerRecord.select("id, student_id, answer_file_url")
              .where(["publish_question_package_id = ? and student_id in (?) and school_class_id = ?",
                         publish_question_package.id, students_id, school_class_id]).uniq
      if student_answer_records.any?
          answer_status_collection = []
          base_url = "#{Rails.root}/public"
          questions_answers = []
          used_times = []
          student_answer_records.each do |sar|
            answer_url = "#{base_url}#{sar.answer_file_url}"
            if File.exist? answer_url
              answer_json = ""
              File.open(answer_url) do |file|
                  file.each do |line|
                    answer_json += line.to_s
                  end
              end
              answer_records = ""
              begin
                answer_records = ActiveSupport::JSON.decode(answer_json)
              rescue
                {:question_types => [], :questions => [], :used_times => [], :questions_answers => []}
              end
                           
              if answer_records.present?
                question_types.each do |types|
                  if answer_records[Question::TYPE_NAME_ARR[types.to_i]].present?
                    if answer_records[Question::TYPE_NAME_ARR[types.to_i]]["questions"].present? && answer_records[Question::TYPE_NAME_ARR[types.to_i]]["use_time"].present?
                      used_times << {:types => types, :use_time => answer_records[Question::TYPE_NAME_ARR[types.to_i]]["use_time"].to_i }
                      answer_records[Question::TYPE_NAME_ARR[types.to_i]]["questions"].each do |question|
                        if question.present? && question["id"].present? && question["branch_questions"].present?
                          correct_rate_arr = question["branch_questions"].map{ |bq| bq["ratio"].to_i }
                          if correct_rate_arr.any?
                            correct_rate = eval(correct_rate_arr.join('+'))/correct_rate_arr.length
                            questions_answers << {:question_id => question["id"].to_i, :types => types, 
                                                  :correct_rate => correct_rate}
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
    end
    p used_times
    {:question_types => question_types, :questions => questions, :used_times => used_times,
       :questions_answers => questions_answers}
  end
end



