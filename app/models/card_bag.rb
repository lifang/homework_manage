class CardBag < ActiveRecord::Base
  attr_protected :authentications
  PER_PAGE = 4
  CARDS_COUNT = 20
  has_many :knowledges_cards, :dependent => :destroy
end
