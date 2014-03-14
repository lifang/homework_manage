#encoding: utf-8
class QuestionPackage < ActiveRecord::Base
  attr_protected :authentications
  has_one :publish_question_package
  has_many :questions, :dependent => :destroy

  #查询一个题包的题目
  def self.get_one_package_questions question_package_id
    questions = []
    sql_str = "select q.id, q.types from question_packages q_p left join questions q
    on q_p.id = q.question_package_id left join branch_questions bq on q.id = bq.question_id
     where q_p.id=#{question_package_id} and bq.id is not null"
    questions = QuestionPackage.find_by_sql sql_str
    questions
  end

  #获得所有题包中的所有题型
  def self.get_all_packs_que_types school_class_id, que_pack_ids
    all_packs_que_types = []
    qp_ids = "#{que_pack_ids}".gsub(/\[/,"(").gsub(/\]/,")")
    sql_str = "select distinct qp.id, q.types from question_packages qp
      left join questions q on qp.id = q.question_package_id
      left join branch_questions bq on q.id = bq.question_id
       where qp.school_class_id = #{school_class_id} and bq.id is not null"
    if qp_ids.scan(/^\(\)$/).length == 0
      sql_str += " and qp.id in #{qp_ids}"
      all_packs_que_types = QuestionPackage.find_by_sql sql_str
    end
    all_packs_que_types
  end
end
