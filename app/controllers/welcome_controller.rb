#encoding: utf-8
class WelcomeController < ApplicationController
  include MethodLibsHelper
  layout 'welcome'
  skip_before_filter :sign?, :get_unread_messes

  #教师登陆
  def login
    email = params[:email].to_s  #需前台验证email地址
    password = params[:password].to_s
    teacher = Teacher.find_by_email_and_status email, Teacher::STATUS[:YES]
    last_visit_class = false
    if teacher.nil?
      status = false
      notice = "用户不存在或者已被停用，请先注册！"
    else
      if teacher && teacher.has_password?(password)
        cookies[:teacher_id]={:value => teacher.id, :path => "/", :secure  => false}
        cookies[:user_id]={:value => teacher.user.try(:id), :path => "/", :secure  => false}

        notice, status, last_visit_class, @redirect_path = redirect_to_different_page(teacher)
      else
        status = false
        notice = "密码错误，登录失败！"
      end
    end
    @info = {:status => status, :notice => notice, :last_visit_class => last_visit_class}
  end

  #注销
  def logout
    cookies[:teacher_id]=nil
    cookies[:user_id]=nil
    cookies.delete(:teacher_id)
    cookies.delete(:user_id)
    cookies.delete(:student_has_ungrouped) if cookies[:student_has_ungrouped]
    flash[:notice] = flash[:notice]
    redirect_to "/"
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
      notice = "该邮箱已被注册或停用，换个邮箱！"
    else
      Teacher.transaction do
        teacher = Teacher.create(:email => email, :password => password,
          :status => Teacher::STATUS[:YES],:types => Teacher::TYPES[:teacher])
        destination_dir = "avatars/teachers/#{Time.now.strftime('%Y-%m')}"
        rename_file_name = "teacher_#{teacher.id}"
        avatar_url = ""
        if !file.nil?
          upload = upload_file destination_dir, rename_file_name, file
          if upload[:status] == true
            avatar_url = upload[:url]
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
            flash[:notice] = "注册完成,请登陆!"
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
    #@teachering_materials = TeachingMaterial.select("id,name")
    if current_teacher
      @teacher = Teacher.find_by_id cookies[:teacher_id]
    else
      flash[:notice] = "请先登录！"
      redirect_to "/"
    end
  end

  #第一次创建班级
  def create_first_class
    name = params[:class_name]
    teaching_material_id = params[:teaching_material_id]
    period_of_validity = params[:period_of_validity].to_s + " 23:59:59"
    verification_code = SchoolClass.get_verification_code
    teacher_id = cookies[:teacher_id]
    teacher = Teacher.find_by_id teacher_id
    status = false
    notice = "班级创建失败，请重新操作！"
    last_visit_class_id = false
    if verification_code < 111111
      notice = "班级验证码生成失败，请重新创建班级！"
      status = false
    elsif verification_code >= 111111 && verification_code <= 999999
      verification_code = verification_code.to_s + rand(9999).to_s
      if teacher.nil?
        notice = "教师不存在，不能创建班级！"
      else
        if teacher.status == Teacher::STATUS[:YES]
          Teacher.transaction do
            @school_class = SchoolClass.create(:name => name,:period_of_validity => period_of_validity,
              :verification_code => verification_code,:status => SchoolClass::STATUS[:NORMAL],
              :teacher_id => teacher.id, :teaching_material_id => teaching_material_id)
            if @school_class.save
              teacher.update_attributes(:last_visit_class_id => @school_class.id)
              flash[:verification_code] = "创建成功,班级验证码为:#{@school_class.verification_code}!"
              status = true
              last_visit_class_id = true
            end
          end
        else
          notice = "教师已被禁用，无法进行操作！"
        end
      end
    else
      notice = "班级可用验证码已到达上限，无法创建班级！"
      status = false
    end
    @info = {:status => status, :notice => notice, :last_visit_class_id => last_visit_class_id}
  end
  #  退出
  def teacher_exit
    params[:school_class_id] = nil
    cookies[:teacher_id] = nil
    cookies[:user_id] = nil
    #    render :index
    redirect_to '/'
  end


  def redirect_to_different_page(teacher)
    redirect_path = ""
    notice = ""
    if teacher.teacher_admin?   #普通教师
      class_id = teacher.last_visit_class_id
      @school_class = class_id.nil? ? nil : SchoolClass.find_by_id(class_id)
      last_visit_class = @class_id.nil? ? false : true
      if @school_class
        if @school_class.status == SchoolClass::STATUS[:EXPIRED] || (@school_class.period_of_validity.to_i - Time.now.to_i) < 0
          @school_classes = teacher.school_classes.
            where("status = #{SchoolClass::STATUS[:NORMAL]} and TIMESTAMPDIFF(SECOND,now(),school_classes.period_of_validity) > 0")
          if @school_classes && @school_classes.length == 0
            status = true
            flash[:notice] = "上次登陆班级失效，请重新创建班级！"
            last_visit_class = false
            redirect_path = "/welcome/first"
          else
            @teachingmaterial = TeachingMaterial.all
            @schoolclasses = SchoolClass.where(:teacher_id => current_teacher.id).where("school_classes.period_of_validity>now()")
            @school_class = @school_classes.first
            teacher.update_attributes(:last_visit_class_id => @school_class.id)
            last_visit_class = true
            status = true
            flash[:notice] = "登陆成功！"
            redirect_path = "/school_classes/#{@school_class.id}/main_pages"
          end
        else
          last_visit_class = true
          status = true
          flash[:notice] = "登陆成功！"
          redirect_path = "/school_classes/#{@school_class.id}/main_pages"
        end
      else
        flash[:notice] = "登陆成功！"
        status = true
        last_visit_class = false
        redirect_path = "/welcome/first"
      end
    elsif teacher.school_admin?
      flash[:notice] = "登陆成功！"
      redirect_path = "/school_manage/teacher_manages"
    elsif teacher.system_admin?
      flash[:notice] = "登陆成功！"
      redirect_path = "/admin/schools"
    elsif teacher.exam_admin?
      flash[:notice] = "登陆成功！"
      redirect_path = "/question_admin/question_manages/new"
    else
      status = false
      notice = "用户没有权限登录！"
    end

    [notice, status, last_visit_class, redirect_path]
  end

  
end
