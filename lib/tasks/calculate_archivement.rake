namespace :calculate_archivement do
  task :archivement => :environment do
    sql_str = "select p.id, p.question_package_id from publish_question_packages p
              where p.is_calc = #{PublishQuestionPackage::IS_CALC[:WAIT]} and
              TIMESTAMPDIFF(MINUTE, now(),p.end_time) < 0"

    #查询截止日期已过期的，未被统计的任务的id及题包的id
    publish_question_packages = PublishQuestionPackage.find_by_sql sql_str
    que_pack_ids = publish_question_packages.map(&:question_package_id)
    sql_str = "select s.id, s.question_package_id, s.student_id, s.school_class_id,
              r.score, r.specified_time,r.used_time, r.question_types
              FROM student_answer_records s left join record_details r
              on s.id = r.student_answer_record_id where r.id is not null
              and s.question_package_id in ();"
    student_answer_details = StudentAnswerRecord
          .joins("LEFT JOIN `record_details` ON student_answer_records.id =
                  record_details.student_answer_record_id")
          .select("DISTINCT student_answer_records.id, student_answer_records.question_package_id,
                  student_answer_records.student_id, student_answer_records.school_class_id,
                  record_details.correct_rate, record_details.score, record_details.specified_time,
                  record_details.used_time, record_details.question_types")
          .where(["record_details.id is not null and (record_details.used_time <= record_details.specified_time )
                  and student_answer_records.question_package_id in (?)",que_pack_ids])
    student_answer_details = student_answer_details.group_by(&:question_package_id)
    qustion_types = [0,1,2,3,4,5,6,7]
    que_pack_ids.each do |que_pack_id|
      if student_answer_details[que_pack_id.to_i].present?
        all_types_records = student_answer_details[que_pack_id.to_i]
        all_types_records = all_types_records.group_by(&:question_types)
        qustion_types.each do |type|
          if all_types_records[type.to_i].present? && all_types_records[type.to_i].length !=0
            all_types_records[type.to_i].sort_by{|r| r.score }.reverse[0..5].each do |one_record|
              archivement = ArchivementsRecord
                .find_by_student_id_and_school_class_id_and_archivement_types(one_record.student_id,
                              one_record.school_class_id, ArchivementsRecord::TYPES[:PEFECT].to_i)
              if archivement.nil?
                archivement = ArchivementsRecord.create(:student_id => one_record.student_id,
                              :school_class_id => one_record.school_class_id,
                              :archivement_types => ArchivementsRecord::TYPES[:PEFECT].to_i,
                              :archivement_score => 10)
              else
                archivement.update_attributes(:archivement_score => (archivement.archivement_score+10))
              end
            end
          end
        end
      end
    end
  end
end
