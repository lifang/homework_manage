#encoding: utf-8
class Question < ActiveRecord::Base
  attr_protected :authentications
  belongs_to :question_package
  has_many :branch_questions, :dependent => :destroy

  TYPES = {:LISTENING => 0, :READING => 1}
  TYPES_NAME = {0 => "听力", 1 => "朗读"}

end
