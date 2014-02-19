#encoding: utf-8
class SchoolClass < ActiveRecord::Base
  attr_protected :authentications
  STATUS = {:NORMAL => 1,:EXPIRED => 0}
  STATUS_NAME = {0 => '班级过期',1 => '正常'}
  belongs_to :teacher
  belongs_to :teaching_material
  has_many :task_messages, :dependent => :destroy
  has_many :microposts, :dependent => :destroy
  has_many :school_class_student_ralastions, :dependent => :destroy
  has_many :students, :through =>  :school_class_student_ralastions
  validates_uniqueness_of :verification_code
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
  end

  def self.get_verification_code
    max_verification_code =  VerificationCode.maximum(:code)
    verification_code = 0
    if max_verification_code.nil?
      verification_code = 1111110000
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
