#encoding: utf-8
class KnowledgesCard < ActiveRecord::Base
  attr_protected :authentications
  belongs_to :card_bag
  belongs_to :branch_question
  has_many :card_tag_knowledges_card_relation, :dependent => :destroy
  MISTAKE_TYPES = {:DEFAULT=>0,:READ => 1, :WRITE => 2, :SELEST => 3}
  MISTAKE_TYPES_NAME = {0 => "默认", 1 => "读错",2 => '写错',3 => '选错'}
  after_save :update_counter_cache
  after_destroy :update_counter_cache
  def update_counter_cache
    self.card_bag.knowledges_cards_count = KnowledgesCard.joins(:branch_question).where("branch_questions.types != #{Question::TYPES[:TIME_LIMIT]} and card_bag_id=#{self.card_bag_id}").count
    self.card_bag.save
  end
end
