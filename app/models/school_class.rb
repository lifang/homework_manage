#encoding: utf-8
class SchoolClass < ActiveRecord::Base
  attr_protected :authentications
  STATUS = {:NORMAL => 1,:EXPIRED => 0}
  STATUS_NAME = {0 => '班级过期',1 => '正常'}
  belongs_to :teacher
  has_many :task_messages, :dependent => :destroy
  has_many :microposts, :dependent => :destroy
  has_many :school_class_student_ralastions, :dependent => :destroy
  has_many :students, :through =>  :school_class_student_ralastions
  validates_uniqueness_of :verification_code
  def self.get_classmates school_class
    classmates_sql = "select s.id, u.name, u.avatar_url, s.nickname from
    school_class_student_ralastions r left join students s on
    r.student_id = s.id left join users u on s.user_id = u.id where
    r.school_class_id = #{school_class.id} and s.status = #{Student::STATUS[:YES]}"
    classmates = SchoolClassStudentRalastion.find_by_sql classmates_sql
  end
end
