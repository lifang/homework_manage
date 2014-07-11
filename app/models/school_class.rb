#encoding: utf-8
class SchoolClass < ActiveRecord::Base
  attr_protected :authentications
  STATUS = {:NORMAL => 1,:EXPIRED => 0}
  STATUS_NAME = {0 => '班级过期',1 => '正常'}
  TYPES = {:dictation => 1, :full => 0} #听写对应的班级还是所有班级
  LEVEL = {:one_up => 1, :one_down => 2, :two_up => 3, :two_down => 4, :tree_up => 5, :tree_down => 6,
            :four_up => 7, :four_down => 8, :five_up => 9, :five_down => 10, :six_up => 11, :six_down =>12,
            :seven_up => 13, :seven_down => 14, :eight_up => 15, :eight_down => 16, :nine_up => 17,
            :nine_down => 18, :ten_up => 19, :ten_down => 20, :eleven_up => 21, :eleven_down => 22, 
            :twelve_up => 23, :twelve_down => 24}
  LEVEL_NAME ={1 =>"一年级上", 2 =>"一年级下", 3 =>"二年级上", 4 =>"二年级下", 5 =>"三年级上", 6 =>"三年级下",
               7 =>"四年级上", 8 =>"四年级下", 9 =>"五年级上", 10 =>"五年级下", 11 =>"六年级上", 12 =>"六年级下",
               13 =>"七年级上", 14 =>"七年级下", 15 =>"八年级上", 16 =>"八年级下", 17 =>"九年级上", 18 =>"九年级下",
               19 =>"十年级上", 20 =>"十年级下", 21 =>"十一年级上", 22 =>"十一年级下", 23 =>"十二年级上", 24 =>"十二年级下"}          
  belongs_to :teacher
  belongs_to :teaching_material
  has_many :task_messages, :dependent => :destroy
  has_many :microposts, :dependent => :destroy
  has_many :tags
  has_many :school_class_student_ralastions, :dependent => :destroy
  has_many :students, :through =>  :school_class_student_ralastions
  validates_uniqueness_of :verification_code
  #获取同班同学信息
  def self.get_classmates school_class, current_student_id=nil
    classmates_sql = "select s.id, u.name, u.avatar_url, s.nickname from
    school_class_student_ralastions r left join students s on
    r.student_id = s.id left join users u on s.user_id = u.id where
    r.school_class_id = #{school_class.id} and s.status = #{Student::STATUS[:YES]}
    "
    if !current_student_id.nil?
      classmates_sql += "and s.id != #{current_student_id} "
    end
    classmates = SchoolClassStudentRalastion.find_by_sql classmates_sql
    classmates_id = classmates.map(&:id).uniq
    archivements_records = ArchivementsRecord
      .where(["student_id in (?) and school_class_id = ?", classmates_id, school_class.id])
      .select("student_id, archivement_score, archivement_types")
      .group_by {|s| s.student_id }
    collections = []
    classmates.each do |classmate|
      if archivements_records[classmate.id] == nil
        archivement = []
      else
        archivement = archivements_records[classmate.id]
      end
      collections << {:id => classmate.id, :name => classmate.name, :avatar_url => classmate.avatar_url,
              :archivement => archivement}
    end
    collections
  end

  def self.get_verification_code
    max_verification_code =  VerificationCode.maximum(:code)
    verification_code = 0
    if max_verification_code.nil?
      verification_code = 111111
      begin
        VerificationCode.create(:code => verification_code)
      rescue
        max_verification_code = VerificationCode.maximum(:code)
        verification_code = max_verification_code + 1
        VerificationCode.create(:code => verification_code)
      end
    else
      max_verification_code =  VerificationCode.maximum(:code)
      verification_code = max_verification_code + 1
      VerificationCode.create(:code => verification_code)
    end
    verification_code
  end
end
