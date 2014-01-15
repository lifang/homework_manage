class User < ActiveRecord::Base
  attr_protected :authentications
  has_many :students
  has_many :teachers
end
