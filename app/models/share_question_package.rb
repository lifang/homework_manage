#encoding: utf-8
class ShareQuestionPackage < ActiveRecord::Base
  belongs_to :teacher, :foreign_key => :created_by
  belongs_to :cell
  belongs_to :episode
  has_many :share_questions, :dependent => :destroy
end