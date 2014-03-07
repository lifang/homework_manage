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
  end
end
