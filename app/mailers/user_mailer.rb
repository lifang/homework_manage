#encoding: utf-8
class UserMailer < ActionMailer::Base
  default from: 'from@example.com'

  def send_pwd_email(email, pwd, type)
    @email, @pwd, @type_name = email, pwd, Teacher::TYPES_NAME[type]
    @url  = '58.240.210.42:3004'   #服务器地址
    mail(to: @email, subject: '欢迎加入超级作业本')
  end
end