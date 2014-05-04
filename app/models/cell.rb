class Cell < ActiveRecord::Base
   attr_protected :authentications
   belongs_to :teaching_material
   has_many :episodes, :dependent => :destroy
   has_many :questions
   has_many :share_questions
end
