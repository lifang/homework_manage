class Student < ActiveRecord::Base
  has_many :school_class_student_ralastions
  has_many :school_classes, :through => :school_class_student_ralastions
end
