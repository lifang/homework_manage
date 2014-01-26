class Cell < ActiveRecord::Base
   attr_protected :authentications
   belongs_to :teaching_material
   has_many :episodes, :dependent => :destroy
end
