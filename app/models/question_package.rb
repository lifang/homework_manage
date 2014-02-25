#encoding: utf-8
class QuestionPackage < ActiveRecord::Base
  attr_protected :authentications
  has_one :publish_question_package
  has_many :questions, :dependent => :destroy

  #查询一个题包的题目
  def self.get_one_package_questions question_package_id
    sql_str = "select q.id, q.types from question_packages q_p left join questions q
    on q_p.id = q.question_package_id where q_p.id=#{question_package_id}"
    questions = QuestionPackage.find_by_sql sql_str
  end

  #获得所有题包中的所有题型
  def self.get_all_packs_que_types school_class_id, que_pack_ids
    qp_ids = "#{que_pack_ids}".gsub(/\[/,"(").gsub(/\]/,")")
    sql_str = "select distinct qp.id, q.types from question_packages qp
      left join questions q on qp.id = q.question_package_id
       where qp.school_class_id = #{school_class_id}"
    if qp_ids.scan(/^\(\)$/).length == 0
      sql_str += " and qp.id in #{qp_ids}"
      all_packs_que_types = QuestionPackage.find_by_sql sql_str
    else
      all_packs_que_types = []
    end
    all_packs_que_types
  end
end
