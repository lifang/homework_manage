class Episode < ActiveRecord::Base
   attr_protected :authentications
   belongs_to :cell
   has_many :questions
end
