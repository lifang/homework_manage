#encoding: utf-8
class StudentsController < ApplicationController
  def index
    sql_schoolclass = "SELECT *,(select COUNT(*) from school_class_student_ralastions scsr WHERE scsr.school_class_id = ?) count
from school_classes sc where sc.id=?"
    @schoolclass = SchoolClass.find_by_sql([sql_schoolclass,school_class_id,school_class_id])
    @tags = Tag.where("school_class_id=#{school_class_id}")
    sql_student = "SELECT s.id,s.nickname,u.name user_name,u.avatar_url,scsr.created_at,t.name tag_name from
    students s LEFT JOIN users u on s.user_id = u.id
LEFT JOIN school_class_student_ralastions scsr on s.id = scsr.student_id LEFT JOIN tags t on scsr.tag_id = t.id  where
 scsr.school_class_id=?"
    student_school_class = Student.find_by_sql([sql_student,school_class_id])
    recorddetail = RecordDetail.joins("inner join student_answer_records sar on record_details.student_answer_record_id = sar.id").
      select("sar.student_id,record_details.id, record_details.score, record_details.correct_rate").
      where("record_details.is_complete= #{RecordDetail::IS_COMPLETE[:FINISH]}").
      where("sar.student_id in (?)",student_school_class.map(&:id))
    recorddetail_group = recorddetail.group_by{|recordde| recordde[:student_id]}.
      map { |k,v|  {:student_id => k,:correct_rate =>v.inject(0){ |arr, a| arr + a[:correct_rate] }/v.length,
        :score =>v.inject(0){ |arr, a| arr + a[:score] }/v.length  }}
    archivementsrecord = ArchivementsRecord.where("school_class_id = #{school_class_id}").group_by{|archivement| archivement[:student_id]}
    @student_situations = []
    student_school_class.each do |student|
      student_situation = student.attributes
      student_situation[:student_id] = student.id
      student_situation[:nickname] = student.nickname
      student_situation[:user_name] = student.user_name
      student_situation[:avatar_url] = student.avatar_url
      student_situation[:created_at] = student.created_at
      student_situation[:tag_name] = student.tag_name
      recorddetail_group.each do |recordd_group|
        if student.id.eql?(recordd_group[:student_id])
          student_situation[:correct_rate] = recordd_group[:correct_rate]
          student_situation[:score] = recordd_group[:score]
        end
      end
      archivementsrecord.each do |student_id,archivement|
        if student.id.eql?(student_id)
          student_situation[:archivement] = archivement
        end
      end
      @student_situations << student_situation
    end
  end

  def delete_student
    student_id = params[:student_id]
    schoolclassstudentralastion = SchoolClassStudentRalastion.find_by_student_id_and_school_class_id student_id,school_class_id
    if schoolclassstudentralastion && schoolclassstudentralastion.destroy
      @notice = "删除成功。"
    else
      @notice = "删除失败！"
    end
    redirect_to "/school_classes/#{school_class_id}/students"
  end
end
