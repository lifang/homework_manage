class VerificationCode < ActiveRecord::Base
  attr_protected :authentications
  validates_uniqueness_of :code
  validates_presence_of :code
end
