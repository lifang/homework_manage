#encoding: utf-8
class Student < ActiveRecord::Base
  attr_protected :authentications
  has_many :school_class_student_ralastions
  has_many :school_classes, :through => :school_class_student_ralastions
end
