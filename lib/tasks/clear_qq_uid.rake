namespace :auto_clear_qq_uid do
  desc "when student has none useful class, clear his qq_uid"  #当学生没有有效的班级，则清空其qq_uid
  task(:clear_qq_uid => :environment) do
    effective_user_sql = "select distinct s.id from students s
       left join school_class_student_ralastions scr on s.id = scr.student_id
       left join school_classes sc on scr.school_class_id = sc.id
       where scr.id is not null and sc.id is not null and sc.status = 1 and 
       TIMESTAMPDIFF(SECOND ,now(),sc.period_of_validity) >= 0 " 
    effective_user_ids = Student.select("distinct students.id id")
            .joins("left join school_class_student_ralastions scr on students.id = scr.student_id")
            .joins("left join school_classes sc on scr.school_class_id = sc.id")
            .where("scr.id is not null and sc.id is not null and sc.status = 1 and 
       TIMESTAMPDIFF(SECOND ,now(),sc.period_of_validity) >= 0")
    effective_user_ids = effective_user_ids.map(&:id)
    # p effective_user_ids
    if effective_user_ids.any?
      Student.where(["id not in (?)", effective_user_ids]).update_all(:qq_uid => nil, :last_visit_class_id => nil)
      SchoolClassStudentRalastion.delete_all(["student_id not in (?)", effective_user_ids])
    end
  end
end
