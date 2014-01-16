#encoding: utf-8
class Message < ActiveRecord::Base
  attr_protected :authentications
  belongs_to :user
end
