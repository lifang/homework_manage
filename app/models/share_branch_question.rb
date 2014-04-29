#encoding: utf-8
class ShareBranchQuestion < ActiveRecord::Base
  attr_protected :authentications
  belongs_to :share_question
  has_many :sbranch_branch_tag_relations
  has_many :branch_tags, :through => :sbranch_branch_tag_relations
end
