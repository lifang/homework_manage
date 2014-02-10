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
end
