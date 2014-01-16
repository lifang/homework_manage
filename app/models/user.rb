class User < ActiveRecord::Base
  attr_protected :authentications
  has_many :students
  has_many :teachers
  has_many :messages, :dependent => :destroy
end
