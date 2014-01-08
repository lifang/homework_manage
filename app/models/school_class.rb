class SchoolClass < ActiveRecord::Base
  attr_protected :authentications
  STATUS = {:NORMAL => 1,:EXPIRED => 0}
  STATUS_NAME = {0 => '课程过期',1 => '正常'}
  belongs_to :teacher
  has_many :school_class_student_ralastions
  has_many :students, :through =>  :school_class_student_ralastions
end
