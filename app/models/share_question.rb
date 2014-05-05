#encoding: utf-8
class ShareQuestion < ActiveRecord::Base
  attr_protected :authentications
  belongs_to :share_question_package
  belongs_to :cell
  belongs_to :episode
  has_many :share_branch_questions, :dependent => :destroy
  require 'will_paginate/array'
  Per_page = 10

  Question::TYPE_NAME_ARR.each do |type|
    scope type.to_sym, :conditions => { :types => Question::TYPES[type.upcase.to_sym] }
  end

  after_save :update_questionpackage_info

  #快捷题包名称
  def question_package_name
    question = ShareQuestion.joins(:cell,:episode).where("share_questions.id=?", self.id).select("cells.name cell_name, episodes.name epi_name").limit(1)[0]
    "#{question.cell_name}#{question.epi_name}作业"
  end
  
  def self.share_questions(cell_id, episode_id, types, sort, page)
    @share_questions = ShareQuestion.find_by_sql("select u.name user_name, sq.* from share_questions sq
inner join users u on sq.user_id = u.id  where sq.types=#{types} and
sq.cell_id=#{cell_id} and sq.episode_id=#{episode_id}
 order by created_at #{sort}").paginate(:page => page || 1, :per_page => Per_page)
  end

  def self.share_question_list user_id,cell_id,episode_id,question_types,page
    sql_question = 'SELECT sq.id,sq.name,sq.types,sq.created_at,c.name cell_name,e.name episode_name
                    from  share_questions sq INNER JOIN cells c on c.id=sq.cell_id
                    INNER JOIN episodes e on e.id=sq.episode_id where sq.user_id = ?'
    sql_question += cell_id + episode_id + question_types + "order by sq.created_at desc"
    @questions = ShareQuestion.paginate_by_sql([sql_question,user_id],:page => page,:per_page=> Per_page)
  end

  def update_questionpackage_info
    share_question_package = self.share_question_package
    if share_question_package && (share_question_package.cell_id.blank? || share_question_package.episode_id.blank? || share_question_package.name.blank?)
      share_question_package.update_attributes(:cell_id => self.cell_id, :episode_id => self.episode_id, :name => self.question_package_name) #分享的题包更新
    end
  end
end
