class Episode < ActiveRecord::Base
   attr_protected :authentications
   belongs_to :cell
end
