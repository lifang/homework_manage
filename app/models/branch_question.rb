#encoding: utf-8
class BranchQuestion < ActiveRecord::Base
  attr_protected :authentications
  belongs_to :question
  BASE_SCORE = 100  #每小题的基础分
end
