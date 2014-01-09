#encoding: utf-8
class Question < ActiveRecord::Base
  attr_protected :authentications
  TYPES = {:LISTENING => 0, :READING => 1}
  TYPES_NAME = {0 => "听力", 1 => "朗读"}
end
