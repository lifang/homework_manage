#encoding: utf-8
class QuestionPackage < ActiveRecord::Base
  attr_protected :authentications
  has_one :publish_question_package
  has_many :questions, :dependent => :destroy

  #查询一个题包的题目
  def self.get_one_package_questions question_package_id
    questions = []
    sql_str = "select distinct q.id, q.types from question_packages q_p left join questions q
    on q_p.id = q.question_package_id where q_p.id=#{question_package_id}"
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

  def self.create_new_question_pack_and_ques(question_pack_id,cell_id,episode_id,question_type, status, school_class_id = nil)
    if question_pack_id.present?
      question_pack = QuestionPackage.find_by_id(question_pack_id)
    else
      question_pack = QuestionPackage.create(:school_class_id => school_class_id)
    end
    if question_pack
      question = question_pack.questions.create({:cell_id => cell_id, :episode_id => episode_id, :types => question_type})
    end
    status = question_pack && question
    [status, question, question_pack]
  end

  def self.find_question_package school_class_id, date
    question_package = []
    question_package =  QuestionPackage.where(["que_pack_date >= '#{date} 00:00:00' and
                                               que_pack_date <= '#{date} 23:59:59' 
                                               and school_class_id = ?", school_class_id])
    p question_package
    if question_package.any?
      return question_package.first
    else
      return QuestionPackage.create(:school_class_id => school_class_id, :que_pack_date => date)
    end 
  end
end
