class KnowledgesCard < ActiveRecord::Base
  attr_protected :authentications
  belongs_to :card_bag, :counter_cache => true
  MISTAKE_TYPES = {:SELEST => 0, :READ => 1, :WRITE => 2}
end
