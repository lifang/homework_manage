#encoding: utf-8
class PublishQuestionPackage < ActiveRecord::Base
  attr_protected :authentications
  belongs_to :teacher
  belongs_to :question_package
  has_one :task_message
  STATUS = {:NEW => 0, :FINISH => 1,:EXPIRED => 2}
  STATUS_NAME = {0 => "新任务", 1 => "完成",2 => '过期'}
  PER_PAGE = 1
end
