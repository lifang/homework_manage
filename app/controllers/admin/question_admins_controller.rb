#encoding: utf-8
class Admin::QuestionAdminsController < ApplicationController
	layout "admin"
  skip_before_filter :get_teacher_infos,:get_unread_messes
  before_filter :check_if_sysadmin, :only => [:index]
  before_filter :get_admin_unread_messes
  def index
    key_word = params[:key_word]
  	@question_admins =  Teacher.question_admin_list key_word, params[:page]
  end

  #修改管理范围
  def change_teaching_materials
    @courses = Course.where("status = #{Course::STATUS[:NORMAL]}")
    @teacher_id = params[:teacher_id]
  end

  def set_teaching_materials
    material_id = params[:material_id]
    course_id = params[:course_id]
    teacher_id = params[:teacher_id]
    @status = false
    @notice = "教材不能为空!"
    if material_id.present?
      teacher = Teacher.find_by_id teacher_id
      p teacher
      if teacher.present?
        if teacher.update_attributes(:teaching_material_id => material_id.to_i)
           @notice = "修改成功!"  
           @status = true
        else
           @notice = "修改失败！"
        end
      else
         @notice = "管理员信息不能为空!"
      end
    end 
  end  

  def set_password
    password = params[:password]
    teacher_id  =  params[:teacher_id]
    teacher  =  Teacher.find_by_id teacher_id
    @status = false
    @notice = "教师信息不能为空!"
    if teacher.present?
      if teacher.update_attributes(:password => password)
        if teacher.update_attributes(:password => teacher.encrypt_password)
          @status = true
          @notice = "密码修改成功!"  
        else
          @notice = "密码修改失败!"  
        end 
      else
        @notice = "密码修改失败!"   
      end  
    end  
  end  

  def disable_teacher
    teacher_id  =  params[:teacher_id]
    teacher  =  Teacher.find_by_id teacher_id
    status = params[:status]
    status = (status.to_i == Teacher::STATUS[:NO]) ? Teacher::STATUS[:YES] : Teacher::STATUS[:NO]
    @status = false
    @notice = "教师信息不能为空!"
    if teacher.present?
      if status == Teacher::STATUS[:YES]
        title = "启用"
      else
        title = "禁用"
      end  
      if teacher.update_attributes(:status => status)
        @status = true
        @notice = "#{title}成功！"  
      else
        @notice = "#{title}失败!"  
      end
    end  
  end 

  def add_question_admin
    name = params[:name]
    email = params[:email]
    material_id = params[:material_id]
    password = random(6)
    @status = false
    @notice = "创建失败！"
    if name && email &&  material_id && password
      teacher = Teacher.find_by_email email
      if teacher.present?
        @notice = "email已存在，请重更换邮箱！"  
      else  
        user = User.create(:name => name)
        teacher = Teacher.create(:email => email, :password => password, :status => Teacher::STATUS[:YES], :types => Teacher::TYPES[:EXAM], 
                              :user_id => user.id, :teaching_material_id => material_id)
        teacher.update_attributes(:password => teacher.encrypt_password)
        UserMailer.send_pwd_email(email,password, Teacher::TYPES[:EXAM]).deliver
        @status = true
        @notice = "创建成功！"
      end  
    end  
  end  

  #加载教材
  def load_materials
    course_id = params[:course_id]
    @materials = TeachingMaterial.where(["course_id = ? and status = ?", course_id, TeachingMaterial::STATUS[:NORMAL]])
  end

  def load_password_panel
    @teacher_id = params[:teacher_id]
  end  

  def load_disable_teacher
    @teacher_id = params[:teacher_id]
    @status = params[:status]
    if @status.to_i == Teacher::STATUS[:YES]
       @title = "禁用" 
    elsif @status.to_i == Teacher::STATUS[:NO]
       @title ="启用"
    end   
  end 

  def load_add_question_admin_panel
    @courses = Course.where("status = #{Course::STATUS[:NORMAL]}")
  end
end