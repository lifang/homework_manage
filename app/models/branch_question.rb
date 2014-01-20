#encoding: utf-8
class BranchQuestion < ActiveRecord::Base
  attr_protected :authentications
  belongs_to :question
end
