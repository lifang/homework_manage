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

  def self.get_publish_question_packages school_class_id, page
    sql_str = "select q.id question_package_id, q.name, p.id publish_question_package_id,
      q.created_at, p.end_time from question_packages q left join publish_question_packages p
      on q.id = p.question_package_id where q.school_class_id = #{school_class_id} order by q.created_at desc"
    publish_question_packages = QuestionPackage.find_by_sql(sql_str).paginate(:page => page, :per_page => PublishQuestionPackage::PER_PAGE)
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
