#encoding: utf-8
class FollowMicropost < ActiveRecord::Base
  attr_protected :authentications
  belongs_to :user
end
