#encoding: utf-8
class SchoolManage::TeacherManagesController < ApplicationController
  layout "school_manage"
  skip_before_filter :get_teacher_infos,:get_unread_messes
  before_filter :check_if_schooladmin, :only => [:index]
  def index
    @teacher_name = params[:teacher_name]
    teacher_name = params[:teacher_name].nil? || params[:teacher_name] == "" ? nil : "%" + params[:teacher_name].strip.to_s + "%"
    if teacher_name.nil?
      @teachers = Teacher.manage_teacher_list current_teacher.school_id,params[:page] ||= 1
    else
      @teachers = Teacher.manage_teacher_list current_teacher.school_id,teacher_name,params[:page] ||= 1
    end
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
    @teachers = Teacher.manage_teacher_list current_teacher.school_id,params[:page] ||= 1
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
  #显示可以过户的班级和教师
  def list_class_and_teacher
    teacher_id = params[:teacher_id]
    @school_class = SchoolClass.where("teacher_id=#{teacher_id}")
    @teachers = Teacher.joins('LEFT JOIN users u ON teachers.user_id = u.id').select("teachers.id,u.name").
      where("teachers.school_id = #{current_teacher.school_id}").where("teachers.types=#{Teacher::TYPES[:teacher]}").where("teachers.id != #{teacher_id}")
  end
  #过户
  def confirm_transfer
    select_school_class_id = params[:select_school_class_id]
    select_teacher_id = params[:select_teacher_id]
    school_class = SchoolClass.find_by_id select_school_class_id
    teacher = Teacher.find_by_id select_teacher_id
    schoolclassstudent = SchoolClassStudentRalastion.where("school_class_id = #{select_school_class_id}").length
    if school_class
      if teacher && teacher.school_id == current_teacher.school_id
        school_class.update_attributes(:teacher_id => teacher.id)
        status = 1
        notice = '过户成功！'
      else
        status = 0
        notice = '教师不存在！'
      end
    else
      status = 0
      notice = '班级不存在！'
    end
    render :json => {:status => status,:notice=> notice,:schoolclassstudent => schoolclassstudent}
  end
end
