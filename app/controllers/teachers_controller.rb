#encoding: utf-8
require 'securerandom'
require 'fileutils'
require "mini_magick"
include MethodLibsHelper
class TeachersController < ApplicationController
  before_filter :sign?
  #教师创建班级
  def create_class
    name = params[:class_name]
    teaching_material_id = params[:teaching_material_id]
    period_of_validity = params[:period_of_validity]
    verification_code = SecureRandom.hex(5)
    teacher_id = cookies[:teacher_id]
    teacher = Teacher.find_by_id teacher_id
    if teacher.nil?
      notice = "教师不存在，不能创建班级！"
      status = false
    else
      if teacher.status == Teacher::STATUS[:YES]
        if teacher.school_classes.create(:name => name,:period_of_validity => period_of_validity,
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
    render :json => {:status => status, :notice => notice}
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
    @user = User.find(current_teacher.user_id)
    @teachingmaterial = TeachingMaterial.all
  end
  #  保存更新
  def save_updated_teacher
    avatar_url = current_user.avatar_url
    file_upload = params[:file_upload]
    if !file_upload.nil?
      destination_dir = "avatars/teachers/#{Time.now.strftime('%Y-%m')}"
      rename_file_name = "teacher_#{current_teacher.id}"
      filename = file_upload.original_filename
      upload = upload_file destination_dir, rename_file_name, file_upload
      if upload[:status] == true
        avatar_url = upload[:url]
        file_path = "#{Rails.root}/public"+avatar_url
        avatar_url = narrow_picture(file_path,rename_file_name,filename,destination_dir)
      end
    end
    if current_user.update_attributes(:name => params[:name],:avatar_url => avatar_url) && current_teacher.update_attributes(:email => params[:email])
      flash[:notice] = "操作成功!"
      redirect_to "/school_classes/#{params[:school_class_id].to_i}/teachers/teacher_setting"
    end
  end
  #  删除班级
  def destroy_classes
    school_class = SchoolClass.find_by_id(params[:id])
    if school_class && school_class.destroy
      flash[:notice] = "操作成功!"
      redirect_to "/school_classes/#{params[:school_class_id].to_i}/teachers/teacher_setting"
    end
  end
  #  切换班级
  def chang_class
    school_class_id = params[:id]
    current_teacher.update_attributes(:last_visit_class_id => school_class_id)
    params[:school_class_id] = school_class_id
    redirect_to "/school_classes/#{params[:school_class_id].to_i}/main_pages"
  end
end
