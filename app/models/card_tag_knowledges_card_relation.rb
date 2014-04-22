class CardTagKnowledgesCardRelation < ActiveRecord::Base
  attr_protected :authentications
  belongs_to :knowleges_card
end
