#encoding: utf-8
require 'digest/sha2'
require 'will_paginate/array'
class Teacher < ActiveRecord::Base
  attr_protected :authentications
  has_many :school_classes, :dependent => :destroy
  has_many :question_packages, :dependent => :destroy
  has_many :publish_question_packages, :dependent => :destroy
  belongs_to :user

  TYPES = {:SYSTEM => 0,:SCHOOL =>1,:EXAM=>2,:teacher=>3}
  TYPES_NAME = {0=>'系统管理员',1=>'学校管理员',2=>'题库管理员',3=>'教师'}
  Types_arr = TYPES.keys
  AVATAR_SIZE = [176]
  SCREENSHOT_SIZE = [298]
  STATUS = {:YES => 0, :NO => 1}
  STATUS_NAME = {0 => '正常', 1 => "失效"}
  TEAVHER_URL = "/assets/default_avater.jpg"

  PER_PAGE = 10
  Types_arr.each do |type|
    define_method "#{type.to_s.downcase}_admin?" do
      self.types == TYPES[type]
    end
  end

  def teacher_valid?
    self.status == STATUS[:YES]
  end

  def teacher_invalid?
    self.status == STATUS[:NO]
  end

  def self.manage_teacher_list school_id,teacher_name=nil,page
    sql_teacher = 'select t.*,COUNT(DISTINCT sc.id) count_class, COUNT(DISTINCT scsr.id) count_student,u.name
from teachers t left JOIN school_classes sc on t.id = sc.teacher_id left JOIN school_class_student_ralastions
scsr on sc.id = scsr.school_class_id INNER JOIN users u on t.user_id = u.id where t.school_id = ? and t.types=? '
    group_teacher_id = 'GROUP BY t.id '
    order_by = "ORDER BY t.created_at desc "
    if teacher_name.nil?
      sql_teacher +=  group_teacher_id + order_by
    else
      sql_teacher += "and u.name like '#{teacher_name}' "  +  group_teacher_id + order_by
    end
    @teachers = Teacher.paginate_by_sql([sql_teacher,school_id,Teacher::TYPES[:teacher]],:per_page => PER_PAGE, :page => page)
  end

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
    que_pack_types = que_pack_types.group_by { |qp| qp.id }
    all_pack_types_name = []
    que_pack_types.each do |id,val|
      type_name = ""
      count = 0
      val.map  do |e| 
        type_name += "、" if count > 0 
        type_name += Question::TYPES_NAME[e.types]
        count += 1
      end  
      type_name = "暂无题目" if  type_name.gsub(" ","").size <= 0
      all_pack_types_name << {:id => id.to_i, :type_name => type_name}
    end
   
    all_pack_types_name = all_pack_types_name.group_by {|e| e[:id]}
    p all_pack_types_name
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

  def self.question_admin_list key_word=nil, page
    where_conddition = []
    where_conddition[0] = "teachers.types = ?"
    where_conddition << Teacher::TYPES[:EXAM]
    if key_word.present?
      where_conddition[0] += " and u.name like '%#{key_word}%'"
    end  
    admins = Teacher
    .select("teachers.id, teachers.email, teachers.status, teachers.password, u.name, t.name material_name")
    .joins("left join users u on teachers.user_id = u.id")
    .joins("left join teaching_materials t on teachers.teaching_material_id = t.id")
    .where(where_conddition).paginate(:page => page, :per_page => Teacher::PER_PAGE)
    .order("teachers.created_at desc")
    admins
  end  

  private
  def encrypt(pwd)
    Digest::SHA2.hexdigest(pwd)
  end
end
