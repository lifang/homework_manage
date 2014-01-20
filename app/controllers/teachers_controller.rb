#encoding: utf-8
require 'securerandom'
include MethodLibsHelper
class TeachersController < ApplicationController
  #教师创建班级
  def create_class
    name = params[:class_name]
    teaching_material_id = params[:teaching_material_id]
    period_of_validity = params[:period_of_validity]
    verification_code = SecureRandom.hex(5)
    teacher_id = session[:teacher_id]
    teacher = Teacher.find_by_id teacher_id
    if teacher.nil?
      notice = "教师不存在，不能创建班级！"
      status = false
    else
      if teacher.status == Teacher::STATUS[:YES]
        if teacher.school_classes.create(:name => name,
            :period_of_validity => period_of_validity,
            :verification_code => verification_code,
            :status => SchoolClass::STATUS[:NORMAL],
            :teaching_material_id => teaching_material_id)
          notice = "班级创建成功！"
          status = true
        else
          notice = "班级创建失败，请重新操作！"
          status = false
        end
      else
        notice = "教师已被禁用，无法进行操作！"
        status = false
      end
    end
    @info = {:status => status, :notice => notice}
  end

  #教师上传头像
  def upload_avatar
    teacher_id = params[:teacher_id]
    avatar = params[:avatar]
    teacher = Teacher.find_by_id teacher_id
    if teacher.nil?
      status = false
      notice = "教师不存在！"
    else
      if teacher.status == Teacher::STATUS[:YES]
      else
        status = false
        notice = "教师已被禁用，无法操作！"
      end
    end
    @info = {:status => status, :notice => notice}
  end
  #  进入设置页面
  def teacher_setting
    @schoolclasses = SchoolClass.where(:teacher_id => current_teacher.id)
    @schoolclass = SchoolClass.find(current_teacher.last_visit_class_id)
    @user = User.find(@teacher.user_id)
    @teachingmaterial = TeachingMaterial.all
  end
  #  保存更新
  def save_updated_teacher
    session[:user_id] = 1
    teacher = Teacher.find(session[:user_id])
    user = User.find(teacher.user_id)
    if user.update_attributes(:name => params[:name]) && teacher.update_attributes(:email => params[:email])
      render :json => {:status => 1}
    else
      render :json => {:status => 0}
    end
  end
#  教师切换班级
  def teacher_switching_classes
    
  end
end
