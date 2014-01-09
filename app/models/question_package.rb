#encoding: utf-8
class QuestionPackage < ActiveRecord::Base
  attr_protected :authentications
  def self.get_questions question_package

  end
end
