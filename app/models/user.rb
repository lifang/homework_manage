class User < ActiveRecord::Base
  attr_protected :authentications
  has_one :student
  has_one :teacher
  has_many :messages, :dependent => :destroy
end
