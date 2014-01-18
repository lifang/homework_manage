module ApplicationHelper
  def is_hover(controller_name)
    request.url.include?(controller_name) ? "hover" : ""
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


  def current_user
    @current_user ||= Teacher.find_by_id(session[:teacher_id]) if session[:teacher_id]
  end
end
