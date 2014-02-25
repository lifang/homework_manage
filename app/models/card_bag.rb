class CardBag < ActiveRecord::Base
  attr_protected :authentications
  PER_PAGE = 2
  CARDS_COUNT = 20
end
