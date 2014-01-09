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

  def self.get_classmates school_class
    classmates = school_class.students.select("students.id,students.name,students.avatar_url,students.nickname").
        where("students.status = #{Student::STATUS[:YES]}")
  end
end
