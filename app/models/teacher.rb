#encoding: utf-8
require 'digest/sha2'
require 'will_paginate/array'
class Teacher < ActiveRecord::Base
  attr_protected :authentications
  has_many :school_classes, :dependent => :destroy
  has_many :question_packages, :dependent => :destroy
  has_many :publish_question_packages, :dependent => :destroy
  belongs_to :user
  AVATAR_SIZE = [176]
  SCREENSHOT_SIZE = [298]
  STATUS = {:YES => 0, :NO => 1}
  STATUS_NAME = {0 => '正常', 1 => "失效"}
  TEAVHER_URL = "/assets/default_avater.jpg"

  def self.get_publish_question_packages school_class_id, page
    sql_str = "select q.id question_package_id, q.name, p.id publish_question_package_id,
      q.created_at, p.status status, p.end_time from question_packages q left join publish_question_packages p
      on q.id = p.question_package_id where q.school_class_id = #{school_class_id} order by q.created_at desc"
    publish_question_packages = QuestionPackage.find_by_sql(sql_str).paginate(:page => page, :per_page => PublishQuestionPackage::PER_PAGE)
    pub_package_id = []
    publish_question_packages.each do |e|
     if e.publish_question_package_id.nil? == false
        pub_package_id << e.publish_question_package_id
     end
    end
    que_packs_id = publish_question_packages.map(&:question_package_id)
    que_pack_types = QuestionPackage.get_all_packs_que_types school_class_id,que_packs_id
    qp_ids = que_pack_types.map(&:id) 
    qp_ids = qp_ids.uniq if qp_ids.present?
    que_pack_types = que_pack_types.group_by { |qp| qp.id }
    all_pack_types_name = []
    qp_ids.each do |id|
      type_name = ""
      if que_pack_types[id].present? 
        count = 0
        que_pack_types[id].each do |e|  
          type_name += "、" if count > 0 
          type_name += Question::TYPES_NAME[e[:types]]
          count += 1
        end  
      end
      type_name = "暂无题目" if  type_name.gsub(" ","").size <= 0
      all_pack_types_name << {:id => id.to_i, :type_name => type_name}
    end
    all_pack_types_name = all_pack_types_name.group_by {|e| e[:id]}
    student_answer_records = StudentAnswerRecord.where("school_class_id = ? and publish_question_package_id in (?)",school_class_id,pub_package_id)
    student_answer_records.map!(&:publish_question_package_id).uniq!
    info = {:publish_question_packages => publish_question_packages, :un_delete => student_answer_records, :all_pack_types_name => all_pack_types_name}
  end

  def has_password?(submitted_password)
    password == encrypt(submitted_password)
  end

  def encrypt_password
    self.password = encrypt(password)
  end

  private
  def encrypt(pwd)
    Digest::SHA2.hexdigest(pwd)
  end
end
