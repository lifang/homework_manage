#encoding: utf-8
class TeachersController < ApplicationController
  #教师登陆
  def login
    username = params[:username].to_s
    password = params[:password].to_s
    teacher = Teacher.where(:username => username).limit(1)[0]
    p teacher
    if teacher.nil?
      status = "error"
      notice = "用户不存在，请先注册！"
    else
      if teacher && teacher.has_password?(password)
        status = "success"
        notice = "登陆成功！"
      else
        status = "error"
        notice = "密码错误，登录失败！"
      end
    end
    @info = {:status => status, :notice => notice}
    render :json => @info
  end

  #教师登陆
  def regist
    username = params[:username].to_s
    password = params[:password].to_s
    teacher = Teacher.where(:username => username).limit(1)[0]
    p teacher
    if teacher.nil?
      status = "error"
      notice = "用户不存在，登录失败！"
    else
      if teacher && teacher.has_password?(password)
        status = "success"
        notice = "登陆成功！"
      else
        status = "error"
        notice = "密码错误，登录失败！"
      end
    end
    @info = {:status => status, :notice => notice}
    render :json => @info
  end
end
