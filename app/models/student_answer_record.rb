#encoding: utf-8
class StudentAnswerRecord < ActiveRecord::Base
  attr_protected :authentications
  belongs_to :student
  has_many :record_details
  STATUS = {:DEALING => 0, :FINISH => 1}
  STATUS_NAME = {0 => "进行中", 1 => "完成"}

  def self.ret_stuent_record(school_class_id, publish_packages_id)
    s_answer_records = StudentAnswerRecord.find_by_sql(["select
           sar.*, u.id user_id, u.name, u.avatar_url
           from students s inner join users u on u.id = s.user_id 
           inner join school_class_student_ralastions r on r.student_id = s.id
           left join student_answer_records sar on sar.student_id = s.id and sar.publish_question_package_id = ?
          where r.school_class_id = ?", publish_packages_id, school_class_id])

    users = s_answer_records.group_by {|i| i.status} if s_answer_records.any?  
    answerd_users = (users and users[STATUS[:FINISH]]) ?  users[STATUS[:FINISH]] : []
    unanswerd_users = s_answer_records ? (s_answer_records - answerd_users) : []
    return [answerd_users, unanswerd_users]
  end

  #获取学生的多种题型答题状态
  def self.get_student_answer_status school_class_id, student_id, pub_ids
    pub_ids = "#{pub_ids}".gsub(/\[/,"(").gsub(/\]/, ")")
    answer_records_sql = "select distinct sar.publish_question_package_id pub_id, rd.question_types types
      from student_answer_records sar left join record_details rd
      on sar.id = rd.student_answer_record_id where sar.school_class_id =#{school_class_id}
      and sar.student_id =#{student_id} and rd.student_answer_record_id is not null
      and rd.is_complete = #{RecordDetail::STATUS[:FINISH]}"
    if pub_ids.scan(/^\(\)$/).length == 0
      answer_records_sql += " and sar.publish_question_package_id in #{pub_ids}"
      student_answer_records = StudentAnswerRecord.find_by_sql answer_records_sql
    else
      student_answer_records = []
    end
    student_answer_records
  end
end
