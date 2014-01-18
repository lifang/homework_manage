#encoding: utf-8
require 'securerandom'
include MethodLibsHelper
class TeachersController < ApplicationController
  #教师登陆
  def login
    email = params[:email].to_s  #需前台验证email地址
    password = params[:password].to_s
    teacher = Teacher.find_by_email email
    p teacher
    if teacher.nil?
      status = false
      notice = "用户不存在，请先注册！"
    else
      if teacher && teacher.has_password?(password)
        session[:user_id] = teacher.id
        status = true
        notice = "登陆成功！"
      else
        status = false
        notice = "密码错误，登录失败！"
      end
    end
    @info = {:status => status, :notice => notice}
  end

  #教师登陆
  def regist
    file = ""
    params.each_with_index do |e,index|
      file = e[1] if index == 0
    end
    email = params[:email].to_s
    name = params[:name].to_s
    password = params[:password].to_s
    #file = params[:avatar]
    teacher = Teacher.find_by_email email
    if !teacher.nil?
      status = "error"
      notice = "该邮箱已被注册，换个邮箱！"
    else
      Teacher.transaction do
        teacher = Teacher.create(:email => email, :password => password,
                                 :status => Teacher::STATUS[:YES])
        destination_dir = "#{Rails.root}/public/homework_system/avatars/teachers/#{Time.now.strftime('%Y-%m')}"
        rename_file_name = "teacher_#{teacher.id}"
        upload = upload_file destination_dir, rename_file_name, file
        if upload[:status] == 0
          url = upload[:url]
          unuse_url = "#{Rails.root}/public"
          avatar_url = url.to_s[unuse_url.size,url.size]
          user = User.create(:name => name, :avatar_url => avatar_url)
          password = teacher.encrypt_password
          if !teacher.nil? && !user.nil?
            if teacher.update_attributes(:password => password, :user_id => user.id)
              status = "success"
              notice = "注册完成！"
            else
              teacher.destroy
              status = "error"
              notice = "注册失败，请重新注册！"
            end
          else
            status = "error"
            notice = "注册失败，请重新注册！"
          end
        else
          status = "error"
          notice = "上传失败，请重新注册！"
        end
      end
    end
    @info = {:status => status, :notice => notice}
    render :json => @info
  end

  #教师创建班级
  def create_class
    name = params[:name]
    period_of_validity = params[:period_of_validity]
    verification_code = SecureRandom.hex(5)
    teacher_id = params[:teacher_id]
    teacher = Teacher.find_by_id teacher_id
    if teacher.nil?
      notice = "教师不存在，不能创建班级！"
      status = "error"
    else
      if teacher.status == Teacher::STATUS[:YES]
        if teacher.school_classes.create(:name => name,
             :period_of_validity => period_of_validity,
             :verification_code => verification_code,
             :status => SchoolClass::STATUS[:NORMAL])
          notice = "班级创建成功！"
          status = "success"
        else
          notice = "班级创建失败，请重新操作！"
          status = "error"
        end
      else
        notice = "教师已被禁用，无法进行操作！"
        status = "error"
      end
    end
    @info = {:status => status, :notice => notice}
    render :json => @info
  end

  #教师上传头像
  def upload_avatar
    teacher_id = params[:teacher_id]
    avatar = params[:avatar]
    teacher = Teacher.find_by_id teacher_id
    if teacher.nil?
      status = "error"
      notice = "教师不存在！"
    else
      if teacher.status == Teacher::STATUS[:YES]
      else
        status = "error"
        notice = "教师已被禁用，无法操作！"
      end
    end
    @info = {:status => status, :notice => notice}
  end
  def teacher_setting_management
    
  end
end
