#encoding: utf-8
class SchoolClassStudentRalastion < ActiveRecord::Base
  attr_protected :authentications
  belongs_to :school_class
  belongs_to :student
  validates_presence_of :student_id
  validates_presence_of :school_class_id
end
