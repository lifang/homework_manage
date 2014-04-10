#encoding: utf-8
class SchoolManage::TeacherManagesController < ApplicationController
  layout "school_manage"
  skip_before_filter :get_teacher_infos
  before_filter :check_if_schooladmin, :only => [:index]
  def index
    @teacher_name = params[:teacher_name]
    teacher_name = params[:teacher_name].nil? || params[:teacher_name] == "" ? nil : "%" + params[:teacher_name].strip.to_s + "%"
    #    current_teacher.school_id
    p current_teacher
    teacher = Teacher.find_by_id current_teacher.id
    p teacher

    sql_teacher = 'select t.*,COUNT(DISTINCT sc.id) count_class, COUNT(DISTINCT scsr.id) count_student,u.name
from teachers t left JOIN school_classes sc on t.id = sc.teacher_id left JOIN school_class_student_ralastions
scsr on sc.id = scsr.school_class_id INNER JOIN users u on t.user_id = u.id where t.school_id = ? and t.types=? '
    group_teacher_id = 'GROUP BY t.id'
    if teacher_name.nil?
      sql_teacher += group_teacher_id
    else
      sql_teacher += "and u.name like '#{teacher_name}' "  + group_teacher_id
    end
    @teachers = Teacher.find_by_sql([sql_teacher,teacher.school_id,Teacher::TYPES[:teacher]])
  end

  #  新建教师
  def create
    teacher_name = params[:teacher_name]
    teacher_email = params[:teacher_email]
    teacher_exit = Teacher.find_by_email teacher_email
    avatar_url = "/assets/default_avater.jpg"
    if teacher_exit
      @status = 0
      @notice = "邮箱已存在！"
    else
      password =random(6)
      school_id = 12
      Teacher.transaction do
        user = User.create(:name => teacher_name,:avatar_url => avatar_url)
        teacher = Teacher.create(:email=>teacher_email,:password=>password,:status=>Teacher::STATUS[:YES],
          :types=>Teacher::TYPES[:teacher],:school_id=>school_id)
        encryptpassword = teacher.encrypt_password
        teacher.update_attributes(:password => encryptpassword,:user_id=>user.id)
        @status = 1
        @notice = '教师创建成功'
        UserMailer.send_pwd_email(teacher_email, password, Teacher::TYPES[:teacher]).deliver
      end
    end
  end
  #  重设密码
  def update_password
    teacher_id = params[:teacher_id]
    password_new = params[:password_new]
    teacher = Teacher.find_by_id teacher_id
    if teacher
      Teacher.transaction do
        teacher.update_attributes(:password => password_new)
        password = teacher.encrypt_password
        teacher.update_attributes(:password => password)
        UserMailer.send_pwd_email(teacher.email, password_new, Teacher::TYPES[:teacher]).deliver
      end
      status = 1
    else
      status = 0
    end
    render :json => {:status => status }
  end
  #  是否停用
  def is_disable
    teacher_id = params[:teacher_id]
    teacher = Teacher.find_by_id teacher_id
    if teacher
      if teacher.status == 0
        teacher.update_attributes(:status => Teacher::STATUS[:NO])
        status = 1
        notice = '教师已禁用。'
      else
        teacher.update_attributes(:status => Teacher::STATUS[:YES])
        status = 2
        notice = '教师已启用。'
      end
    else
      status = 0
      notice = '教师不存在！'
    end
    render :json => {:status => status,:notice => notice}
  end
end
