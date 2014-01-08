class SchoolClassStudentRalastion < ActiveRecord::Base
  belongs_to :school_class
  belongs_to :student
  validates_presence_of :student_id
  validates_presence_of :school_class_id
end
