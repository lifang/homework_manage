#encoding: utf-8
class Micropost < ActiveRecord::Base
  attr_protected :authentications
  belongs_to :school_class
  USER_TYPES = {:TEACHER => 0, :STUDENT => 1}
  USER_TYPES_NAME = {0 => '教师', 1 => '学生'}

  def self.get_microposts school_class
    microposts = school_class.microposts.select("id, content, user_id, user_types,created_at")
  end
end
