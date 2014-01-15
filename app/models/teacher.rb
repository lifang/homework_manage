#encoding: utf-8
require 'digest/sha2'
class Teacher < ActiveRecord::Base
  attr_protected :authentications
  has_many :school_classes, :dependent => :destroy
  has_many :question_packages, :dependent => :destroy
  has_many :publish_question_packages, :dependent => :destroy
  belongs_to :user
  STATUS = {:YES => 0, :NO => 1}
  STATUS_NAME = {0 => '正常', 1 => "失效"}

  def has_password?(submitted_password)
    password == encrypt(submitted_password)
  end

  def encrypt_password
    self.password = encrypt(password)
  end

  private
  def encrypt(pwd)
    Digest::SHA2.hexdigest(pwd)
  end
end
