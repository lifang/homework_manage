#encoding: utf-8
class PublishQuestionPackage < ActiveRecord::Base
  attr_protected :authentications
  STATUS = {:NEW => 0, :FINISH => 1}
  STATUS_NAME = {0 => "新任务", 1 => "完成"}
end
