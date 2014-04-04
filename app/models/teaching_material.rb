class TeachingMaterial < ActiveRecord::Base
   attr_protected :authentications
   has_many :cells, :dependent => :destroy
   has_many :school_classed, :dependent => :nullify

   STATUS = {:DELETED => 0, :NORMAL => 1}  #状态 0已删除 1正常
end
