#encoding: utf-8
class School< ActiveRecord::Base
  attr_protected :authentications
  STATUS = {:DELETE => 0,:NORMAL => 1}
  STATUS_NAME = {0=>'已删除',1=>'正常'}
  PER_PAGE = 10
  def self.newpass( len )
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newpass = ""
    1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
    return newpass
  end

  def self.schools_list schools_name=nil,page
    sql_school = "SELECT schools.*, t.email FROM schools inner join teachers t on schools.id=t.school_id
WHERE t.types=#{Teacher::TYPES[:SCHOOL]} "
    if !schools_name.nil?
      sql_school += "and schools.name like '#{schools_name}'"
    end
    @schools = School.paginate_by_sql(sql_school,:per_page => PER_PAGE, :page => page)
  end

  #获取配额消费列表
  def self.quota_consumptions_list school_id, page=nil
    quota_consumptions = []
    if school_id.present?
      teachers = Teacher.where("school_id = ?",school_id) if school_id.present?
      teachers_id = teachers.map(&:id)
      school_classes = SchoolClass.where(["teacher_id in (?)", teachers_id])
      school_classes_id = school_classes.map(&:id)
      if school_classes_id.any?
        quota_consumptions = SchoolClassStudentsRelation
                               .select("s.s_no, sc.name class_name, u.name, DATE_FORMAT(school_class_students_relations.created_at, '%Y-%m-%d %H:%i:%S') created_at")
                               .joins("left join students s on school_class_students_relations.student_id = s.id")
                               .joins("left join users u on s.user_id = u.id")
                               .joins("left join school_classes sc on school_class_students_relations.school_class_id = sc.id")
                               .where(["school_class_students_relations.school_id = ? and school_class_students_relations.school_class_id in (?)", 
                                                      school_id, school_classes_id])                       
      end                               
    end 
    quota_consumptions                             
  end
end
