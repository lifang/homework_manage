class Course < ActiveRecord::Base
   attr_protected :authentications
   has_many :teaching_materials
end
