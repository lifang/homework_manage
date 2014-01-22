#encoding: utf-8
class ShareQuestion < ActiveRecord::Base
  attr_protected :authentications
  has_many :share_branch_questions, :dependent => :destroy
  require 'will_paginate/array'

  def self.share_questions(question, sort, page)
    @share_questions = ShareQuestion.find_by_sql("select u.name user_name, sq.* from share_questions sq
inner join users u on sq.user_id = u.id where sq.types=#{question.types} and
sq.cell_id=#{question.cell_id} and sq.episode_id=#{question.episode_id}
 order by created_at #{sort}").paginate(:page => page || 1, :per_page => 10)
  end
end
