#encoding: utf-8
class ShareQuestionPackage < ActiveRecord::Base
  belongs_to :teacher, :foreign_key => :created_by
  belongs_to :cell
  belongs_to :episode
  has_many :share_questions, :dependent => :destroy

  def self.get_each_type(share_question_packages)
    all_share_questions = ShareQuestion.where(:share_question_package_id => share_question_packages.map(&:id))
    .group_by{|sq| sq.share_question_package_id}
    question_types = {}
    all_share_questions.each do |sqp, share_questions|
      all_types = share_questions.map{|sq| sq.types}.compact.uniq
      question_types[sqp] = all_types.map{|types| Question::TYPES_NAME[types]}.join("、")
    end
    question_types
  end
end