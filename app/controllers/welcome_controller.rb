#encoding: utf-8
class WelcomeController < ApplicationController
#  before_filter :sign?,:only => [:create_first_class]
  layout 'welcome'
  def index
  end

  #教师登陆
  def login
    email = params[:email].to_s  #需前台验证email地址
    password = params[:password].to_s
    teacher = Teacher.find_by_email email
    last_visit_class = false
    if teacher.nil?
      status = false
      notice = "用户不存在，请先注册！"
    else
      if teacher && teacher.has_password?(password)
        if teacher.last_visit_class_id.to_i != 0
          last_visit_class = true
          session[:class_id]  = teacher.last_visit_class_id
        end
        session[:teacher_id] = teacher.id
        session[:user_id] = teacher.user.id
        status = true
        notice = "登陆成功！"
      else
        status = false
        notice = "密码错误，登录失败！"
      end
    end
    @info = {:status => status, :notice => notice, :last_visit_class => last_visit_class}
  end

  #教师注册
  def regist
    email = params[:email].to_s
    name = params[:name].to_s
    password = params[:password].to_s
    file = params[:avatar]
    teacher = Teacher.find_by_email email
    status = false
    notice = "注册失败，请重新注册！"
    if !teacher.nil?
      status = false
      notice = "该邮箱已被注册，换个邮箱！"
    else
      Teacher.transaction do
        teacher = Teacher.create(:email => email, :password => password,
          :status => Teacher::STATUS[:YES])
        destination_dir = "#{Rails.root}/public/homework_system/avatars/teachers/#{Time.now.strftime('%Y-%m')}"
        rename_file_name = "teacher_#{teacher.id}"
        avatar_url = ""
        if !file.nil?
          upload = upload_file destination_dir, rename_file_name, file
          if upload[:status] == true
            url = upload[:url]
            unuse_url = "#{Rails.root}/public"
            avatar_url = url.to_s[unuse_url.size,url.size]
          else
            avatar_url = "/assets/default_avater.jpg"
          end
        else
          avatar_url = "/assets/default_avater.jpg"
        end
        user = User.create(:name => name, :avatar_url => avatar_url)
        password = teacher.encrypt_password
        if !teacher.nil? && !user.nil?
          if teacher.update_attributes(:password => password, :user_id => user.id)
            status = true
            notice = "注册完成！"
          else
            teacher.destroy
            user.destroy
          end
        end
      end
    end
    @info = {:status => status, :notice => notice}
  end

  #教师第一次注册后跳转页面
  def first
    @teachering_materials = TeachingMaterial.select("id,name")
    @teacher = Teacher.find_by_id session[:teacher_id]
  end

  #第一次创建班级
  def create_first_class
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
        Teacher.transaction do
          @school_class = SchoolClass.new(:name => name,:period_of_validity => period_of_validity,
            :verification_code => verification_code,:status => SchoolClass::STATUS[:NORMAL],
            :teacher_id => teacher.id, :teaching_material_id => teaching_material_id)
          if @school_class.save
            teacher.update_attributes(:last_visit_class_id => @school_class.id)
            session[:class_id] = @school_class.id
            notice = "班级创建成功！"
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
    @info = {:status => status, :notice => notice}
  end
  #  退出
  def teacher_exit
    session[:class_id] = nil
    session[:teacher_id] = nil
    session[:user_id] = nil
    #    render :index
    redirect_to '/'
  end
end
