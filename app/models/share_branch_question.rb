#encoding: utf-8
class ShareBranchQuestion < ActiveRecord::Base
  attr_protected :authentications
  belongs_to :share_question
  has_many :sbranch_branch_tag_relations
  has_many :branch_tags, :through => :sbranch_branch_tag_relations

  def self.bunch_branch_tags(share_branch_questions_ids)
    branch_tags = SbranchBranchTagRelation.find_by_sql(["select bt.name, bbr.share_branch_question_id, bbr.branch_tag_id, bq.share_question_id
        from sbranch_branch_tag_relations bbr left join branch_tags bt on bbr.branch_tag_id=bt.id
        left join share_branch_questions bq on bq.id = bbr.share_branch_question_id
        where bbr.share_branch_question_id in (?)", share_branch_questions_ids])
    return branch_tags
  end
end
