class UserPropRelation < ActiveRecord::Base
  attr_protected :authentications
  belongs_to :student
  belongs_to :prop
end
