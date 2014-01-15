#encoding: utf-8
class ReplyMicropost < ActiveRecord::Base
  attr_protected :authentications
  belongs_to :micropost
  #def self.get_reply_microposts school_class, page, user_id=nil
end
