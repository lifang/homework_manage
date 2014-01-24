#encoding: utf-8
module ApplicationHelper
  MEDIA_PATH = "/question_packages/#{Time.now.strftime("%Y%m")}/questions_package_%d/" #大题资源路径
  
  def is_hover(*controller_names)
    controller_names.each do |name|
      if request.url.include?(name)
        return "hover"
      end
    end
  end

  def is_show_zuoye_tab(*controller_names)
    controller_names.each do |name|
      if request.url.include?(name)
        return "block"
      end
    end
    return "none"
  end

  def get_user_info uid, utype  #通过id和type获取老师或者学生的姓名及头像图片
    if utype.to_i == Micropost::USER_TYPES[:TEACHER]
      user = Teacher.find_by_sql(["select u.name, u.avatar_url from teachers t inner join users u
          on t.user_id=u.id where t.id=?", uid]).first
    elsif utype.to_i == Micropost::USER_TYPES[:STUDENT]
      user = Student.find_by_sql(["select u.name, u.avatar_url from students s inner join users u
          on s.user_id=u.id where s.id=?", uid]).first
    end
    return user
  end
  def get_school_class
    @school_class = SchoolClass.find_by_id(current_teacher.last_visit_class_id)
    @class_index =-1
    @index =-1
  end

  def current_user
    @current_user ||= User.find_by_id(cookies[:user_id]) if cookies[:user_id]
  end

  def current_teacher
    @current_teacher ||= Teacher.find_by_id(cookies[:teacher_id]) if cookies[:teacher_id]
  end

  def school_class_id
    @school_class_id ||= current_teacher.last_visit_class_id if current_teacher
  end

  def current_school_class
    @school_class ||= SchoolClass.find_by_id(school_class_id) if school_class_id
  end
  
  def sign?
    unless request.xhr?
      if cookies[:user_id].nil?  || cookies[:teacher_id].nil?

        redirect_to  "/"
      #else
      #  unless params[:school_class_id].nil?
          #if action_name != "chang_class" && school_class_id != params[:school_class_id].to_i
          #  flash[:notice] = "没有权限访问"
          #  redirect_to  "/"
          #end
        #end
      end
    end
  end
end
