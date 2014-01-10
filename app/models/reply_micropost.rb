#encoding: utf-8
class ReplyMicropost < ActiveRecord::Base
  attr_protected :authentications
  belongs_to :micropost
end
