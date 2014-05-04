#encoding: utf-8
class BranchQuestion < ActiveRecord::Base
  attr_protected :authentications
  belongs_to :question
  has_many :btags_bque_relations
  has_many :branch_tags, :through => :btags_bque_relations
  has_many :knowledges_cards
  BASE_SCORE = 100  #每小题的基础分

  def self.bunch_branch_tags(branch_questions_ids)
    branch_tags = BtagsBqueRelation.find_by_sql(["select bt.name, bbr.branch_question_id, bbr.branch_tag_id,bq.question_id
        from btags_bque_relations bbr left join branch_tags bt on bbr.branch_tag_id=bt.id
        left join branch_questions bq on bq.id = bbr.branch_question_id
        where bbr.branch_question_id in (?) and bt.id is not null", branch_questions_ids])
    return branch_tags
  end
end
