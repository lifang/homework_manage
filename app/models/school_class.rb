class SchoolClass < ActiveRecord::Base
  attr_protected :authentications
  belongs_to :teacher
  has_many :school_class_student_ralastions
  has_many :students, :through =>  :school_class_student_ralastions
end
