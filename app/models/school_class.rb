#encoding: utf-8
class SchoolClass < ActiveRecord::Base
  attr_protected :authentications
  STATUS = {:NORMAL => 1,:EXPIRED => 0}
  STATUS_NAME = {0 => '班级过期',1 => '正常'}
  TYPES = {:dictation => 1, :full => 0} #听写对应的班级还是所有班级
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
