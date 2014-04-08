class TeachingMaterial < ActiveRecord::Base
   attr_protected :authentications
   has_many :cells, :dependent => :destroy
   has_many :school_classed, :dependent => :nullify
   belongs_to :course
end
