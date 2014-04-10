#encoding: utf-8
class SchoolManage::TeacherManagesController < ApplicationController
  layout "school_manage"
  skip_before_filter :get_teacher_infos
  before_filter :check_if_schooladmin, :only => [:index]
  def index
    current_school = 12
    sql = "select * from teachers where school_id = 12 and types=3"
    @teachers = Teacher.find_by_sql(sql)
  end

  #  新建教师
  def create
    p 111111111
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
  def is_enable

  end
end
