#encoding: utf-8
class ShareQuestion < ActiveRecord::Base
  attr_protected :authentications
  has_many :share_branch_questions, :dependent => :destroy
end
