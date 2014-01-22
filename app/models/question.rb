#encoding: utf-8
class Question < ActiveRecord::Base
  attr_protected :authentications
  belongs_to :question_package
  has_many :branch_questions, :dependent => :destroy

  TYPE_NAME_ARR = ["listening", "reading"]
  TYPES = {:LISTENING => 0, :READING => 1}
  TYPES_TITLE = {0 => "listening", 1 => "reading"}
  TYPES_NAME = {0 => "听力", 1 => "朗读"}

  TYPE_NAME_ARR.each do |type|
    scope type.to_sym, :conditions => { :types => TYPES[type.upcase.to_sym] }
  end

  #查询一个题包下的所有题目
  def self.get_all_questions question_package
    all_questions = []
    sql_str = "SELECT q.id,q.types, b.id branch_question_id, b.content, b.resource_url FROM questions q
        left join branch_questions b on q.id = b.question_id
        where q.question_package_id =#{question_package.id} and b.id != 'null'"
    all_questions = Question.find_by_sql sql_str
  end
end
