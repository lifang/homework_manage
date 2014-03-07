#encoding: utf-8
class StudentsController < ApplicationController
  def index
    #    SELECT s.id,s.nickname,u.name user_name,u.avatar_url,scsr.created_at,t.name tag_name from
    #students s,users u,school_class_student_ralastions scsr ,tags t where
    #s.id = scsr.student_id and s.user_id = u.id and scsr.tag_id = t.id  and scsr.school_class_id=56

    sql = "SELECT s.id,s.nickname,u.name,u.avatar_url,scsr.created_at from
students s,users u,school_class_student_ralastions scsr where
s.id = scsr.student_id and s.user_id = u.id and scsr.school_class_id=?"
    student_school_class = Student.find_by_sql([sql,school_class_id])
    recorddetail = RecordDetail.joins("inner join student_answer_records sar on record_details.student_answer_record_id = sar.id").
      select("sar.student_id,record_details.id, record_details.score, record_details.correct_rate").
      where("record_details.is_complete= #{RecordDetail::IS_COMPLETE[:FINISH]}").
      where("sar.student_id in (?)",student_school_class.map(&:id))
    recorddetail_group = recorddetail.group_by{|recordde| recordde[:student_id]}.
      map { |k,v|  {:student_id => k,:correct_rate =>v.inject(0){ |arr, a| arr + a[:correct_rate] }/v.length,
        :score=>v.inject(0){ |arr, a| arr + a[:score] }/v.length  }}
    archivementsrecord = ArchivementsRecord.where("school_class_id = #{school_class_id}").group_by{|archivement| archivement[:student_id]}
    student_situations = []
    student_school_class.each do |student|
      student_situation = student.attributes
      student_situation[:student_id] = student.id

    end
  end
end
