#encoding: utf-8
class Admin::QuestionAdminsController < ApplicationController
	layout "admin"
  
  def index
  	school_class_id = params[:school_class_id]
  	school_class_id = 1
  	@question_admins =  Teacher
  				.select("teachers.id, teachers.email, teachers.password, u.name, t.name material_name")
  				.joins("left join users u on teachers.user_id = u.id")
  				.joins("left join teaching_materials t on teachers.teaching_material_id = t.id")
  				.where(["teachers.types = ? and teachers.school_id = ?", Teacher::TYPES[:EXAM], school_class_id])
  end

  def create
    
  end

  #修改管理范围
  def change_teaching_materials
    @courses = Course.all
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
    @status = false
    @notice = "教师信息不能为空!"
    if teacher.present?
      if teacher.update_attributes(:status => Teacher::STATUS[:NO])
        @status = true
        @notice = "禁用成功！"  
      else
        @notice = "禁用失败!"  
      end
    end  
  end 

  #加载教材
  def load_materials
    course_id = params[:course_id]
    @materials = TeachingMaterial.where(["course_id = ?", course_id])
  end

  def load_password_panel
    @teacher_id = params[:teacher_id]
  end  

  def load_disable_teacher
    @teacher_id = params[:teacher_id]
  end 

end