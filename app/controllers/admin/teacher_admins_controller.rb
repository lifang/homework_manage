#encoding: utf-8
class Admin::TeacherAdminsController < ApplicationController
  layout "admin"
  def index
    p 111111111111
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
      
    end
  end
  #  重设密码
  def update

  end
  #  是否停用
  def is_enable
    
  end
end
