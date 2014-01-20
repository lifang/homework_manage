#encoding: utf-8
class ShareBranchQuestion < ActiveRecord::Base
  attr_protected :authentications
  belongs_to :share_question
end
