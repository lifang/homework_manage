#encoding: utf-8
class BtagsBqueRelation < ActiveRecord::Base
  attr_accessible :branch_question_id, :branch_tag_id
  belongs_to :branch_tag
  belongs_to :branch_question
end
