#encoding: utf-8
class Admin::SchoolsController < ApplicationController
	layout "admin"
  skip_before_filter :get_teacher_infos
  before_filter :check_if_sysadmin, :only => [:index]
	def index
    @schools_name = params[:schools_name]
    schools_name = params[:schools_name].nil? || params[:schools_name] == "" ? nil : "%" + params[:schools_name].strip.to_s + "%"
    if schools_name.nil?
      @schools = School.schools_list params[:page] ||= 1
    else
      @schools = School.schools_list schools_name,params[:page] ||= 1
    end
	end

  def create
    school_name = params[:school_name]
    school_students_count = params[:school_students_count]
    email = params[:email]
    school_exist = School.find_by_name school_name
    teacher_exit = Teacher.find_by_email email
    avatar_url = "/assets/default_avater.jpg"
    if school_exist || teacher_exit
      @status = 0
      @notice = "学校和邮箱已存在！"
    else
      if school_name.nil? || school_students_count.nil?
        @status = 0
        @notice = "学校名称和学校配额不能为空!"
      else
        School.transaction do
          password =random(6)
          p password
          school = School.create(:name =>school_name,:students_count=> school_students_count,:status => School::STATUS[:NORMAL],:used_school_counts => 0 )
          user = User.create(:name => school_name,:avatar_url => avatar_url)
          teacher = Teacher.create(:password => password,:email => email,:types => Teacher::TYPES[:SCHOOL],:status=>Teacher::STATUS[:YES],
            :user_id => user.id,:school_id => school.id)
          encryptpassword = teacher.encrypt_password
          teacher.update_attributes(:password => encryptpassword)
          @status = 1
          UserMailer.send_pwd_email(email, password, Teacher::TYPES[:SCHOOL]).deliver
        end
      end
    end
    @schools = School.schools_list params[:page] ||= 1
  end

  #调整配额
  def adjust_quotas
    students_count = params[:students_count]
    school_id = params[:school_id]
    school = School.find_by_id school_id
    admin = Teacher.find_by_types Teacher::TYPES[:SYSTEM]
    teacher = Teacher.find_by_school_id school_id
    if school && school.update_attributes(:students_count => students_count)
      content = "额度调整为" + students_count
      if admin && teacher
        AdminMessage.create(:sender_id=>admin.id,:receiver_id=>teacher.id,:content => content)
      end
      status = 1
      notice = "调整成功！"
      count_show = school.used_school_counts.to_s + "/" + students_count
    else
      status = 0
      notice = "调整失败！"
    end
    render :json => {:status => status,:notice => notice,:count_show => count_show}
  end

  #  修改密码
  def update_school_password
    school_id = params[:school_id]
    password_new = params[:password_new]
    school_teacher = Teacher.find_by_school_id_and_types school_id,Teacher::TYPES[:SCHOOL]
    if school_teacher
      Teacher.transaction do
        school_teacher.update_attributes(:password => password_new)
        password = school_teacher.encrypt_password
        school_teacher.update_attributes(:password => password)
        UserMailer.send_pwd_email(school_teacher.email, password_new, Teacher::TYPES[:SCHOOL]).deliver
      end
      status = 1
    else
      status = 0
    end
    render :json => {:status => status}
  end

  #停用或者启用
  def is_enable
    school_id = params[:school_id]
    school = School.find_by_id school_id
    teacher = Teacher.find_by_school_id school_id
    if school
      if school.status
        school.update_attributes(:status=>School::STATUS[:DELETE])
        teacher.update_attributes(:status=>Teacher::STATUS[:NO])
        status = 1
        notice = '学校已禁用！'
      else
        school.update_attributes(:status=>School::STATUS[:NORMAL])
        teacher.update_attributes(:status=>Teacher::STATUS[:YES])
        status = 2
        notice = '学校已启用！'
      end
    else
      status = 0
      notice = '学校不存在！'
    end
    render :json => {:status => status,:notice=>notice}
  end
end