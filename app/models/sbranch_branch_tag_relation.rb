class SbranchBranchTagRelation < ActiveRecord::Base
    attr_accessible :share_branch_question_id, :branch_tag_id
  belongs_to :branch_tag
  belongs_to :share_branch_question
end