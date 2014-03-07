#encoding: utf-8
class Student < ActiveRecord::Base
  attr_protected :authentications
  STATUS = {:YES => 0, :NO => 1}
  STATUS_NAME = {0 => "正常", 1 => "失效"}
  has_many :school_class_student_ralastions
  has_many :school_classes, :through => :school_class_student_ralastions
  has_many :student_answer_records, :dependent => :destroy
  has_many :user_prop_relations, :dependent => :destroy
  has_many :props, :through => :user_prop_relations
  belongs_to :user
  validates_uniqueness_of :qq_uid
end
