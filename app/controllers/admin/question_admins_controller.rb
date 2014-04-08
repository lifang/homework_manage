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
  	
  end 	
end