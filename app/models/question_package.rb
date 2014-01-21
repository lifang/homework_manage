#encoding: utf-8
class QuestionPackage < ActiveRecord::Base
  attr_protected :authentications
  has_one :publish_question_package
  has_many :questions, :dependent => :destroy

end
