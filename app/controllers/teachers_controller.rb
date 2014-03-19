#encoding: utf-8
require 'securerandom'
require 'fileutils'
require "mini_magick"
include MethodLibsHelper
class TeachersController < ApplicationController
  before_filter :sign?, :get_unread_messes
  #教师创建班级
  def create_class
    name = params[:class_name]
    teaching_material_id = params[:teaching_material_id]
    period_of_validity = params[:period_of_validity]
    verification_code = SchoolClass.get_verification_code
    if verification_code < 111111
      notice = "班级验证码生成失败，请重新创建班级！"
      status = false
    elsif verification_code >= 111111 && verification_code <= 999999
      verification_code = verification_code.to_s + rand(9999).to_s
      teacher_id = cookies[:teacher_id]
      teacher = Teacher.find_by_id teacher_id
      teacher_id
      school_classes = SchoolClass.find_by_teacher_id_and_name(teacher_id,name)
      if teacher.nil?
        notice = "教师不存在，不能创建班级！"
        status = false
      else
        if teacher.status == Teacher::STATUS[:YES]
          if !school_classes.nil?
            notice = "班级班级已存在！"
            status = false
          else
            if @school_class = teacher.school_classes.create(:name => name,:period_of_validity => period_of_validity,
                :verification_code => verification_code,
                :status => SchoolClass::STATUS[:NORMAL],
                :teaching_material_id => teaching_material_id)
              #            notice = "班级创建成功！"
              flash[:verification_code] = "创建成功,班级验证码为:#{@school_class.verification_code}!"
              status = true
            else
              notice = "班级创建失败，请重新操作！"
              status = false
            end
          end
        else
          notice = "教师已被禁用，无法进行操作！"
          status = false
        end
      end
    else
      notice = "班级可用验证码已到达上限，无法创建班级！"
      status = false
    end
    render :json => {:status => status, :notice => notice}
  end

  #教师上传头像
  def upload_avatar
    file_upload = params[:file_upload]
    if !file_upload.nil?
      if file_upload.size > 1048576
        @status = "imgbig"
        @src = ""
      else
        img = MiniMagick::Image.read(file_upload)
        img.format("jpg") if file_upload.content_type =~ /gif|png$/i   #把别的格式改为jpg
        destination_dir = "avatars/teachers/#{Time.now.strftime('%Y-%m')}"
        rename_file_name = "teacher_#{current_teacher.id}"
        FileUtils.mkdir_p("#{Rails.root}/public/#{destination_dir}") if !Dir.exist? ("#{Rails.root}/public/#{destination_dir}")
        img.write "#{Rails.root}/public/#{destination_dir}/#{rename_file_name}.jpg"
        @status = "true"
        @src = "/#{destination_dir}/#{rename_file_name}.jpg"
      end
    else
      @status = "false"
      @src = ""
    end
  end
  #  进入设置页面
  def teacher_setting
    @schoolclasses = SchoolClass.where(:teacher_id => current_teacher.id)
    @schoolclass = SchoolClass.find(current_teacher.last_visit_class_id)
    @user = User.find(current_teacher.user_id)
    @teachingmaterial = TeachingMaterial.all
  end
  # 更新头像
  def update_avatar
    avatar_url = current_user.avatar_url
    file_path = "#{Rails.root}/public/avatars/teachers/#{Time.now.strftime('%Y-%m')}/teacher_#{current_teacher.id}.jpg"
    img  = MiniMagick::Image.open(file_path)
    Teacher::SCREENSHOT_SIZE.each do |size|
      resize = size>img["width"] ? img["width"] :size
      new_file = file_path.split(".")[0]+"_"+resize.to_s+"."+ file_path.split(".").reverse[0]
      if img["width"]>img["height"]
        img.run_command("convert #{file_path} -resize 298x298 #{new_file}")
      else
        resize = 298/(img["width"].to_f/img["height"])
        img.run_command("convert #{file_path} -resize #{resize}x#{resize} #{new_file}")
      end
      if avatar_url.eql?(Teacher::TEAVHER_URL)
        file_paths = "#{Rails.root}/public/avatars/teachers/#{Time.now.strftime('%Y-%m')}/teacher_#{current_teacher.id}_1.jpg"
        avatar_url = "/avatars/teachers/#{Time.now.strftime('%Y-%m')}/teacher_#{current_teacher.id}_1.jpg"
      else
        index_name = avatar_url.split("_")[2]
        index_a = index_name.split(".")[0].to_i + 1
        file_used_paths = "#{Rails.root}/public#{avatar_url}"
        File.delete file_used_paths  if File.exist?(file_used_paths)
        file_paths = "#{Rails.root}/public/avatars/teachers/#{Time.now.strftime('%Y-%m')}/teacher_#{current_teacher.id}_#{index_a}.jpg"
        avatar_url = "/avatars/teachers/#{Time.now.strftime('%Y-%m')}/teacher_#{current_teacher.id}_#{index_a}.jpg"
      end
      imgs  = MiniMagick::Image.open(new_file)
      imgs.run_command("convert #{new_file} -crop #{params[:w].to_i}x#{params[:h].to_i}+#{params[:x].to_i}+#{params[:y].to_i} #{file_paths}")
    end
    if current_user.update_attributes(:avatar_url => avatar_url)
      flash[:notice] = "操作成功!"
      redirect_to "/school_classes/#{params[:school_class_id].to_i}/main_pages"
    end
  end
  #  保存更新
  def save_updated_teacher
    if current_user.update_attributes(:name => params[:name]) && current_teacher.update_attributes(:email => params[:email].strip)
      flash[:notice] = "操作成功!"
      redirect_to "/school_classes/#{params[:school_class_id].to_i}/main_pages"
    end
  end
  #  删除班级
  def destroy_classes
    sql_schoolclass = "SELECT *,(select COUNT(*) from school_class_student_ralastions scsr WHERE scsr.school_class_id = ?) count
from school_classes sc where sc.id=?"
    @schoolclass = SchoolClass.find_by_sql([sql_schoolclass,school_class_id,school_class_id])
    school_class = SchoolClass.find_by_id(params[:id])
    @schoolclasses = SchoolClass.where(:teacher_id => current_teacher.id)
    if school_class && school_class.destroy
      flash[:notice] = "操作成功!"
      @status = 1
    else
      @status = 0
    end
  end
  #  切换班级
  def chang_class
    school_class_id = params[:id]
    current_teacher.update_attributes(:last_visit_class_id => school_class_id)
    params[:school_class_id] = school_class_id
    redirect_to "/school_classes/#{params[:school_class_id].to_i}/students"
  end
  # 修改密码
  def update_password
    password_now = params[:password_now].to_s   #当前密码
    password_update = params[:password_update].to_s  #要修改的密码
    password_update_agin = params[:password_update_agin].to_s #重新输入密码
    if current_teacher && current_teacher.has_password?(password_now)
      if password_update.eql?(password_update_agin)
        Teacher.transaction do
          current_teacher.update_attributes(:password => password_update_agin)
          password = current_teacher.encrypt_password
          current_teacher.update_attributes(:password => password)
        end
        notice = "密码修改成功！"
        status = true
      else
        notice = "两次输入密码不一致！"
        status = false
      end
    else
      notice = "教师密码输入不正确！"
      status = false
    end
    render :json => {:status => status, :notice => notice}
  end
end
