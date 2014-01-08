#encoding: utf-8
class TaskMessage < ActiveRecord::Base
  attr_protected :authentications
  belongs_to :school_class
  STATUS = {:YES => 0, :NO => 1}
  STATUS_NAME = {0 => "正常", 1 => "失效"}
end
