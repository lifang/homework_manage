#encoding: utf-8
class Admin::SchoolsController < ApplicationController
	layout "admin"
	def index
    @schools = School.schools_list
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
    else
      School.transaction do
        password =School.newpass(6)
        school = School.create(:name =>school_name,:students_count=> school_students_count,:status => School::STATUS[:NORMAL],:used_school_counts => 0 )
        user = User.create(:name => school_name,:avatar_url => avatar_url)
        teacher = Teacher.create(:password => password,:email => email,:types => Teacher::TYPES[:SCHOOL],:status=>Teacher::STATUS[:YES],
          :user_id => user.id,:school_id => school.id)
        encryptpassword = teacher.encrypt_password
        teacher.update_attributes(:password => encryptpassword)
        @status = 1
      end
    end
    @schools = School.schools_list
  end

  #调整配额
  def adjust_quotas
    students_count = params[:students_count]
    school_id = params[:school_id]
    school = School.find_by_id school_id
    if school && school.update_attributes(:students_count => students_count)
      @status = 1
    else
      @status = 0
    end
    @schools = School.schools_list
  end

  #  修改密码
  def update_school_password
    school_id = params[:school_id]
    password_new = params[:password_new]
    p 1111,school_id,password_new
    school_teacher = Teacher.find_by_school_id school_id
    if school_teacher
      Teacher.transaction do
        school_teacher.update_attributes(:password => password_new)
        password = school_teacher.encrypt_password
        school_teacher.update_attributes(:password => password)
      end
      status = 1
    else
      status = 0
    end
    render :json => {:status => status}
  end

  # 查询班级
  def search_schools
    
  end
end