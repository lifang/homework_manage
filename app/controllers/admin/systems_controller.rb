#encoding: utf-8
class Admin::SystemsController < ApplicationController
  layout "admin"
  skip_before_filter :get_teacher_infos

  def reset_password
    sys_user = Teacher.find_by_id params[:teacher_id]
    new_password = params[:password]
    if sys_user
      sys_user.update_attribute(:password, Digest::SHA2.hexdigest(new_password))
      UserMailer.reset_pwd_email(sys_user.email, new_password, sys_user.types).deliver  #发送新密码到邮件
    end
  end

  def disable_enable_account
    sys_user = Teacher.find_by_id params[:teacher_id]
    if sys_user.teacher_valid?
      @notice = "账号已被禁用"
      sys_user.update_attribute(:status, Teacher::STATUS[:NO])
    else
      @notice = "账号重新启用"
      sys_user.update_attribute(:status, Teacher::STATUS[:YES])
    end
  end
  
end