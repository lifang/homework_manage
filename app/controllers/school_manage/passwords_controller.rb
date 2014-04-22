#encoding: utf-8
class SchoolManage::PasswordsController < ApplicationController

  def reset_password
    old_pwd, new_pwd = params[:password], params[:new_password]
    Teacher.transaction do
      if current_teacher && current_teacher.has_password?(old_pwd)
        current_teacher.update_attributes(:password => Digest::SHA2.hexdigest(new_pwd))
        flash[:notice] = "密码已改变，请重新登录!"
        notice = "密码修改成功！"
        status = true
      else
        notice = "密码错误！修改失败"
        status = false
      end
      @info = {:status => status, :notice => notice}
    end
  end
end