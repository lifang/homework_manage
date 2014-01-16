class User < ActiveRecord::Base
  attr_protected :authentications
  has_one :student
  has_one :teacher
end
