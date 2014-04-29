#encoding: utf-8
class BranchQuestion < ActiveRecord::Base
  attr_protected :authentications
  belongs_to :question
  has_many :btags_bque_relations
  has_many :branch_tags, :through => :btags_bque_relations
  has_many :knowledges_cards
  BASE_SCORE = 100  #每小题的基础分
end
