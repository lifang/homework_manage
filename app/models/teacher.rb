#encoding: utf-8
class Teacher < ActiveRecord::Base
  attr_protected :authentications
  has_many :school_classes, :dependent => :destroy
  has_many :question_packages, :dependent => :destroy
  has_many :publish_question_packages, :dependent => :destroy
  STATUS = {:YES => 0, :NO => 1}
  STATUS_NAME = {0 => '正常', 1 => "失效"}
end
