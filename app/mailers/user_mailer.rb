#encoding: utf-8
class UserMailer < ActionMailer::Base
  default from: ' mailer@comdosoft.com'
  $url = 'http://58.240.210.42:3004'   #服务器地址
  def send_pwd_email(email, pwd, type)
    p 1111111111111111111111111
    @email, @pwd, @type_name = email, pwd, Teacher::TYPES_NAME[type]
    @url  = $url
    mail(to: @email, subject: '欢迎加入超级作业本')
  end

  def reset_pwd_email(email, pwd, type)
    @email, @pwd, @type_name = email, pwd, Teacher::TYPES_NAME[type]
    @url  = $url   #服务器地址
    mail(to: @email, subject: '重置密码')
  end

  def apply_quota_consumptions(email, sender_name, school_name, number, type)
    @email, @type_name, @school_name, @number, @sender_name = email, Teacher::TYPES_NAME[type], school_name, number, sender_name  
    mail(to: @email, subject: '申请学生配额')
  end  
end