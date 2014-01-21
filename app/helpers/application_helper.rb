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
    @school_class = SchoolClass.find_by_id(session[:class_id].to_i)
    @class_index =-1
    @index =-1
  end

  def current_user
    @current_user ||= User.find_by_id(session[:user_id]) if session[:user_id]
  end

  def current_teacher
    @current_teacher ||= Teacher.find_by_id(session[:teacher_id]) if session[:teacher_id]
  end


  def sign?
    if session[:user_id].nil?
      redirect_to  "/"
    end
  end
end
