class KnowledgesCard < ActiveRecord::Base
  attr_protected :authentications
  belongs_to :card_bag, :counter_cache => true
  has_many :card_tag_knowledges_card_relation, :dependent => :destroy
  MISTAKE_TYPES = {:DEFAULT=>0,:READ => 0, :WRITE => 1, :SELEST => 2}
  MISTAKE_TYPES_NAME = {0 => "默认", 1 => "读错",2 => '写错',3 => '选错'}
end
