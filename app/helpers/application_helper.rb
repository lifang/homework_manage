#encoding: utf-8
module ApplicationHelper
#  MEDIA_PATH = "/question_packages/#{Time.now.strftime("%Y%m")}/questions_package_%d/" #大题资源路径
#  SAHRE_MEDIA_PATH = "/question_packages/#{Time.now.strftime("%Y%m")}/share_questions_package_%d/" #大题分享资源路径
  def media_path
    if cookies[:teacher_id]
     return "/question_packages/#{cookies[:teacher_id]}/questions_package_%d/"
    end
  end
  def share_media_path
    if cookies[:teacher_id]
      return "/question_packages/#{cookies[:teacher_id]}/share_questions_package_%d/"
    end
  end
  #题库管理员的资源路径
  def question_admin_share_media_path
    if cookies[:teacher_id]
      return "/question_packages/#{cookies[:teacher_id]}/qa_share_questions_package_#{Time.now.strftime('%Y%m')}/"
    end
  end
  
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
        flash[:notice] = "请先登陆!"
        redirect_to  "/"
      else
        unless params[:school_class_id].nil?
          if action_name != "chang_class" && school_class_id != params[:school_class_id].to_i
            flash[:notice] = "没有权限访问"
            cookies.delete(:teacher_id)
            cookies.delete(:user_id)
            redirect_to  "/"
          end
        end
      end
    end
  end

  #获取未读信息提示
  def get_unread_messes
    school_class_id = params[:school_class_id].to_i
    @unread_messes = Message.where(["user_id =? and school_class_id = ? and status = ?",
        cookies[:user_id].to_i, school_class_id, Message::STATUS[:NOMAL]]).order("created_at desc")
  end

  #获取题目标签
  def get_branch_tags teacher_id
    branch_tags = BranchTag.where(["teacher_id is null or teacher_id = ?", teacher_id])
    return branch_tags
  end

  #生成随机密码
  def random(limit)
    strong_alphanumerics = %w{
          a b c d e f g h i j k l m n o p q r s t u v w x y z
          A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
          1 2 3 4 5 6 7 8 9
    }
    Array.new(limit, "").collect{strong_alphanumerics[rand(61)]}.join
  end


  #分享的题目，双击填写题目
  def share_question_title(question_id)
    question_id = question_id.to_s
    '<span></span><a href="javascript:void(0)" class="amendName tooltip_html" data-id=' + question_id + '>修改名称</a>'
  end
end
