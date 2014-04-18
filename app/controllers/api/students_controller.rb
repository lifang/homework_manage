#encoding: utf-8
require 'xml_to_json/string'
require 'rexml/document'
include REXML
require 'json'
include MethodLibsHelper
class Api::StudentsController < ApplicationController
  skip_before_filter :get_teacher_infos,:sign?,:get_unread_messes
  #  发布消息
  def news_release
    content = params[:content] 
    user_id = params[:user_id]
    user_types = params[:user_types]
    school_class_id = params[:school_class_id]
    micropost = Micropost.new(:user_id => user_id, :user_types => user_types, 
      :content => content, :school_class_id => school_class_id, :reply_microposts_count => 0)
    if micropost.save
      micropost_return = Micropost.find_by_sql(["SELECT m.*,DATE_FORMAT(m.created_at, '%Y-%m-%d %H:%i:%S') as new_created_at, u.avatar_url,u.name from microposts m INNER JOIN users u on m.user_id = u.id where m.id = ?",micropost.id])
      render :json => {:status => 'success', :notice => '消息发布成功',:micropost=>micropost_return}
    else
      render :json => {:status => 'error', :notice => '消息发布失败',:micropost=>[]}
    end
  end
  #  回复消息
  def reply_message
    sender_id = params[:sender_id]
    sender_types = params[:sender_types]
    content = params[:content].strip
    micropost_id = params[:micropost_id]
    reciver_id = params[:reciver_id]
    reciver_types = params[:reciver_types]
    school_class_id = params[:school_class_id]
    micropost = Micropost.find_by_id micropost_id.to_i
    if micropost
      replymicropost = ReplyMicropost.new(:sender_id => sender_id,
        :sender_types => sender_types, :content => content,
        :micropost_id => micropost_id, :reciver_id => reciver_id,:reciver_types => reciver_types)
      replymicropost.save
      replymicropost_return = ReplyMicropost.find_by_sql(["select rm.id, rm.content, rm.sender_id, rm.sender_types, rm.reciver_id, rm.praise, DATE_FORMAT(rm.created_at, '%Y-%m-%d %H:%i:%S') as new_created_at, s.name sender_name,
              s.avatar_url sender_avatar_url, u.name reciver_name, u.avatar_url reciver_avatar_url
              from reply_microposts rm left join
              users s on rm.sender_id = s.id left join users u on rm.reciver_id = u.id
              where  rm.id=?",replymicropost.id])
      micropost.update_attributes(:reply_microposts_count => (micropost.reply_microposts_count + 1))
      Message.add_messages(replymicropost, school_class_id)  #pc端显示回复的message
      render :json => {:status => 'success', :notice => '消息回复成功',:replymicropost => replymicropost_return}
    else
      render :json => {:status => 'error', :notice => '消息回复失败',:replymicropost=>[] }
    end
  end
  
  #  关注消息api
  def add_concern
    user_id = params[:user_id].to_i
    micropost_id = params[:micropost_id].to_i
    followmicropost = FollowMicropost.find_by_user_id_and_micropost_id(user_id,micropost_id)
    if followmicropost.nil?
      Micropost.transaction do
        micropost = Micropost.find_by_id micropost_id
        follow_micropost_count = micropost.follow_microposts_count.to_i + 1
        followmicropost = FollowMicropost.new(:user_id => user_id, :micropost_id => micropost_id)
        micropost.update_attributes(:follow_microposts_count => follow_micropost_count)
      end
      if followmicropost.save
        render :json => {:status => 'success', :notice => '关注添加成功'}
      else
        render :json => {:status => 'error', :notice => '关注添加失败'}
      end
    else
      render :json => {:status => 'success', :notice => '该消息您已关注，请勿重复提交关注！'}
    end
  end
  #  取消关注
  def unfollow
    user_id = params[:user_id].to_i
    micropost_id = params[:micropost_id].to_i
    micropost = Micropost.find_by_id micropost_id
    followmicropost_exits = FollowMicropost.find_by_user_id_and_micropost_id(user_id, micropost_id)
    if followmicropost_exits && followmicropost_exits.destroy
      if micropost.follow_microposts_count && micropost.follow_microposts_count > 0
        follow_micropost_count = micropost.follow_microposts_count.to_i - 1
        micropost.update_attributes(:follow_microposts_count => follow_micropost_count)
      end
      render :json => {:status => 'success', :notice => '取消关注成功'}
    else
      render :json => {:status => 'error', :notice => '取消关注失败'}
    end
  end
  #显示班级列表
  def get_my_classes
    student_id = params[:student_id].to_i
    classes = SchoolClass.find_by_sql(["SELECT school_classes.id class_id,school_classes.name class_name, 
              DATE_FORMAT(school_classes.period_of_validity , '%Y-%m-%d %H:%i:%S') as period_of_validity
            from school_classes INNER JOIN school_class_student_ralastions 
            on school_classes.id = school_class_student_ralastions.school_class_id
            where school_classes.status = ? and school_classes.period_of_validity >= ?
            and school_class_student_ralastions.student_id = ?", 
        SchoolClass::STATUS[:NORMAL], Time.now(), student_id])
    if classes
      status = "success"
      notice = "获取成功！"
    else
      status = "error"
      notice = "获取失败！"
      classes= []
    end
    render :json => {:status=> status,:notice=>notice,:classes => classes}
  end
  
  #我的消息
  def my_microposts    
    school_class = SchoolClass.find_by_id params[:school_class_id].to_i
    micropost_hash = {}
    if school_class
      micropost_hash = Micropost.get_microposts school_class, params[:page], params[:user_id]
      if (params[:page].nil? or params[:page] == "1") and micropost_hash[:details_microposts].length == 0
        notice = "当前班级下暂无消息。"
      end
      status = true
    else
      notice = "请检查您所查看的班级是否已失效。"
      status = false
    end
    micropost_hash.merge!({:notice => notice, :status => status})
    render :json => micropost_hash
  end

  #获取我关注的消息
  def get_follow_microposts
    school_class_id = params[:school_class_id]
    student_id = params[:student_id]
    page = params[:page].to_i
    student = Student.find_by_id student_id
    school_class = SchoolClass.find_by_id school_class_id
    page = 1 if page == 0
    microposts = []
    pages_count = 0
    status = "error"
    notice = "获取失败！"
    if !student.nil? && !school_class.nil?
      follow_microposts_record = FollowMicropost.where("user_id = ?",student.user_id)
      follow_microposts_id = follow_microposts_record.map{|m| m.micropost_id }
      follow_microposts_id = follow_microposts_id.to_s.gsub(/\[|\]/,"")
      if follow_microposts_id.size > 0
        sql_str = "select m.id micropost_id, m.user_id, m.user_types, m.content, DATE_FORMAT(m.created_at, '%Y-%m-%d %H:%i:%S') as new_created_at,
                m.reply_microposts_count, m.follow_microposts_count, u.name, u.avatar_url
                from microposts m inner join users u on u.id = m.user_id
                where m.school_class_id = #{school_class.id} and m.id in (#{follow_microposts_id})
                order by m.created_at desc"
        microposts = Micropost.paginate_by_sql(sql_str, :per_page => Micropost::PER_PAGE, :page => page)
        pages_count = microposts.total_pages
        status = "success"
        notice = "获取成功！"
      else
        microposts = []
        status = "success"
        notice = "您还未关注任何消息！"
      end
    end
    render :json => {:status => status, :notice => notice, :microposts => microposts,
      :pages_count => pages_count, :page => page}
  end

  #qq登陆
  def login
    qq_uid = params[:open_id]
    student = Student.find_by_qq_uid qq_uid
    if student.nil?
      render :json => {:status => "error", :notice => "账号不存在，请先注册！"}
    else
      student.update_attribute(:token, params[:token])
      if student.status != Student::STATUS[:YES]
        render :json => {:status => "error", :notice => "该学生已被禁用!"}
      else
        school_status = "false"
        if student.school_id.present?
          school = School.find_by_id student.school_id
          if school.present? && school.status == true
            school_status = "true"
          else
            render :json => {:status => "error", :notice => "没有找到该学生所属的学校或该学校已被禁用!"}  
          end
        else
          school_status = "none"
        end  
        if school_status == "true" || school_status == "none"
          school_class = SchoolClass.find_by_id student.last_visit_class_id.to_i
          c_s_relation = SchoolClassStudentRalastion
              .find_by_student_id_and_school_class_id(student.id,student.last_visit_class_id)
          if c_s_relation.nil? || school_class.nil?
            if school_status == "true"
              school_classes = SchoolClassStudentRalastion
                    .select("sc.id")
                    .joins("left join school_classes sc on school_class_student_ralastions.school_class_id = sc.id")
                    .joins("left join teachers t on sc.teacher_id = t.id")
                    .joins("left join schools s on t.school_id = s.id")
                    .where("sc.status = #{SchoolClass::STATUS[:NORMAL]} and t.status = #{Teacher::STATUS[:YES]} and TIMESTAMPDIFF(SECOND,now(),sc.period_of_validity) > 0 and s.status =#{School::STATUS[:NORMAL]}")
            else
              school_classes = SchoolClassStudentRalastion
                    .select("sc.id")
                    .joins("left join school_classes sc on school_class_student_ralastions.school_class_id = sc.id")
                    .joins("left join teachers t on sc.teacher_id = t.id")
                    .where("sc.status = #{SchoolClass::STATUS[:NORMAL]} and t.status = #{Teacher::STATUS[:YES]} and TIMESTAMPDIFF(SECOND,now(),sc.period_of_validity) > 0")        
            end        
            if school_classes && school_classes.any?
              school_class_id = school_classes.first.id
              school_class = SchoolClass.find_by_id school_class_id
              class_id = school_class.id
              class_name = school_class.name
              tearcher_id = school_class.teacher.id
              tearcher_name = school_class.teacher.user.name
              page = 1
              microposts = Micropost.get_microposts school_class,page
              follow_microposts_id = Micropost.get_follows_id microposts, student.user.id
              student.update_attributes(:last_visit_class_id => school_class.id)
              render :json => {:status => "success", :notice => "登录成功！",
                :student => {:id => student.id, :name => student.user.name, :user_id => student.user.id,
                  :nickname => student.nickname, :s_no => student.s_no, :avatar_url => student.user.avatar_url},
                :class => {:id => class_id, :name => class_name, :tearcher_name => tearcher_name,
                  :tearcher_id => tearcher_id , :period_of_validity => school_class.period_of_validity.strftime("%Y-%m-%d %H:%M:%S") },
                :microposts => microposts,
                :follow_microposts_id => follow_microposts_id,
              }
            else
              render :json => {:status => "error", :notice => "上次访问的班级已失效!!"}    
            end    
          else
            if school_class.nil? || school_class.status == SchoolClass::STATUS[:EXPIRED] || (school_class.period_of_validity - Time.now) < 0 || school_class.tearcher.status != Teacher::STATUS[:YES]
                if school_status == "true"
                  school_classes = SchoolClassStudentRalastion
                        .select("sc.id")
                        .joins("left join school_classes sc on school_class_student_ralastions.school_class_id = sc.id")
                        .joins("left join teachers t on sc.teacher_id = t.id")
                        .joins("left join schools s on t.school_id = s.id")
                        .where("sc.status = #{SchoolClass::STATUS[:NORMAL]} and t.status = #{Teacher::STATUS[:YES]} 
                            and TIMESTAMPDIFF(SECOND,now(),sc.period_of_validity) > 0 and s.status =#{School::STATUS[:NORMAL]}")
                else
                  school_classes = SchoolClassStudentRalastion
                        .select("sc.id")
                        .joins("left join school_classes sc on school_class_student_ralastions.school_class_id = sc.id")
                        .joins("left join teachers t on sc.teacher_id = t.id")
                        .where("sc.status = #{SchoolClass::STATUS[:NORMAL]} and t.status = #{Teacher::STATUS[:YES]} 
                            and TIMESTAMPDIFF(SECOND,now(),sc.period_of_validity) > 0")        
                end        
                if school_classes && school_classes.any?
                  school_class_id = school_classes.first.id
                  school_class = SchoolClass.find_by_id school_class_id
                  class_id = school_class.id
                  class_name = school_class.name
                  tearcher_id = school_class.teacher.id
                  tearcher_name = school_class.teacher.user.name
                  page = 1
                  microposts = Micropost.get_microposts school_class,page
                  follow_microposts_id = Micropost.get_follows_id microposts, student.user.id
                  student.update_attributes(:last_visit_class_id => school_class.id)
                  render :json => {:status => "success", :notice => "登录成功！",
                    :student => {:id => student.id, :name => student.user.name, :user_id => student.user.id,
                      :nickname => student.nickname, :s_no => student.s_no, :avatar_url => student.user.avatar_url},
                    :class => {:id => class_id, :name => class_name, :tearcher_name => tearcher_name,
                      :tearcher_id => tearcher_id , :period_of_validity => school_class.period_of_validity.strftime("%Y-%m-%d %H:%M:%S") },
                    :microposts => microposts,
                    :follow_microposts_id => follow_microposts_id,
                  }
                else
                  render :json => {:status => "error", :notice => "上次访问的班级已失效!!"}    
                end  
            else               
              class_id = school_class.id
              class_name = school_class.name
              tearcher_id = school_class.teacher.id
              tearcher_name = school_class.teacher.user.name
              page = 1
              microposts = Micropost.get_microposts school_class,page
              follow_microposts_id = Micropost.get_follows_id microposts, student.user.id
              student.update_attributes(:last_visit_class_id => school_class.id)
              render :json => {:status => "success", :notice => "登录成功！",
                :student => {:id => student.id, :name => student.user.name, :user_id => student.user.id,
                  :nickname => student.nickname, :s_no => student.s_no, :avatar_url => student.user.avatar_url},
                :class => {:id => class_id, :name => class_name, :tearcher_name => tearcher_name,
                  :tearcher_id => tearcher_id , :period_of_validity => school_class.period_of_validity.strftime("%Y-%m-%d %H:%M:%S") },
                :microposts => microposts,
                :follow_microposts_id => follow_microposts_id,
              }
            end
          end  
        end
      end  
    end
  end

  #获取当天最新任务
  def get_newer_task
    student_id = params[:student_id]
    school_class_id = params[:school_class_id]
    student = Student.find_by_id student_id
    school_class = SchoolClass.find_by_id school_class_id
    status = "error"
    notice = "获取失败！"
    tasks = nil
    knowledges_cards_count = nil
    props = nil
    if !student.nil? && !school_class.nil?
      card_bag = CardBag.find_by_school_class_id_and_student_id school_class_id,student_id
      if card_bag.present?
        knowledges_cards_count = card_bag.knowledges_cards_count
      end
      props = Prop.get_prop_num school_class.id, student.id
      tasks = PublishQuestionPackage.get_tasks school_class.id, student.id,"first"
      status = "success"
      notice = "获取成功！"
    end
    render :json => {:status => status, :notice => notice, :tasks => tasks,
                    :knowledges_cards_count=> knowledges_cards_count, :props => props}
  end

  #获取历史任务
  def get_more_tasks
    student_id = params[:student_id]
    school_class_id = params[:school_class_id]
    today_newer_id = params[:today_newer_id]
    student = Student.find_by_id student_id
    school_class = SchoolClass.find_by_id school_class_id
    status = "error"
    notice = "获取失败！"
    tasks = nil
    props = nil
    knowledges_cards_count = nil
    if !student.nil? && !school_class.nil?
      card_bag = CardBag.find_by_school_class_id_and_student_id school_class_id,student_id
      if card_bag.present?
        knowledges_cards_count = card_bag.knowledges_cards_count
      end
      props = Prop.get_prop_num school_class.id, student.id
      tasks = PublishQuestionPackage.get_tasks school_class.id, student.id, nil, nil, today_newer_id
      status = "success"
      notice = "获取成功！"
    end
    render :json => {:status => status, :notice => notice, :tasks => tasks,
                     :knowledges_cards_count=> knowledges_cards_count, :props => props}
  end

  #查询任务
  def search_tasks
    student_id = params[:student_id]
    school_class_id = params[:school_class_id]
    date = params[:date]
    student = Student.find_by_id student_id
    school_class = SchoolClass.find_by_id school_class_id
    status = "error"
    notice = "查询出错！"
    tasks = nil
    knowledges_cards_count = nil
    props = nil
    if !student.nil? && !school_class.nil? && !date.nil?
      card_bag = CardBag.find_by_school_class_id_and_student_id school_class_id,student_id
      if card_bag.present?
        knowledges_cards_count = card_bag.knowledges_cards_count
      end
      props = Prop.get_prop_num school_class.id, student.id
      tasks = PublishQuestionPackage.get_tasks school_class.id, student.id, nil, date
      status = "success"
      notice = "查询完成！"
    end
    render :json => {:status => status, :notice => notice, :tasks => tasks, :props => props,
                     :knowledges_cards_count => knowledges_cards_count}
  end

  #获取题包内容
  def get_question_package_details
    student_id = params[:student_id]
    school_class_id = params[:school_class_id]
    publish_question_package_id = params[:publish_question_package_id]
    student = Student.find_by_id student_id
    school_class = SchoolClass.find_by_id school_class_id
    publish_question_package = PublishQuestionPackage
    .find_by_id publish_question_package_id
    status = "error"
    notice = "获取出错！"
    answer_url = nil
    props = nil
    if !student.nil? && !school_class.nil? && !publish_question_package.nil?
      status = "error"
      notice = "获取完成！"
      question_packages_url = publish_question_package.question_packages_url
      student_answer_record = StudentAnswerRecord
      .find_by_student_id_and_publish_question_package_id(student.id,publish_question_package.id)
      if !student_answer_record.nil? && !student_answer_record.answer_file_url.nil?
        answer_url =  student_answer_record.answer_file_url
        props = Prop.get_prop_num school_class.id, student.id
      end
    end
    render :json => {:status => status, :notice => notice,
      :question_packages_url => question_packages_url,
      :answer_url => answer_url, :props => props}
  end

  #获取消息microposts(分页)
  def get_microposts
    school_class_id = params[:school_class_id]
    student_id = params[:student_id]
    page = params[:page].to_i
    school_class = SchoolClass.find_by_id school_class_id
    student = Student.find_by_id student_id
    microposts = nil
    follow_microposts_id = nil
    status = "error"
    if student.nil?
      notice = "学生信息错误"
    else
      if school_class.nil?
        notice = "班级不存在"
      else
        school_class_student_relations = SchoolClassStudentRalastion.
          find_by_school_class_id_and_student_id school_class.id, student.id
        if school_class_student_relations.nil?
          status = "error"
          notice = "学生不属于该班级"
        else
          if school_class.status == SchoolClass::STATUS[:NORMAL]
            if page.nil?
              notice = "页数为空"
            else
              status = "success"
              notice = "加载完成"
              microposts = Micropost.get_microposts school_class,page
              follow_microposts_id = Micropost.get_follows_id microposts, student.user.id
            end
          else
            notice = "班级已过期"
            microposts = nil
          end
        end
      end
    end
    render :json => {:status => status, :notice => notice,:microposts => microposts,
      :follow_microposts_id => follow_microposts_id}
  end
  #  更新个人信息
  def modify_person_info
    user_attr = {}
    user_attr[:name] = params[:name] if params[:name]
    #user_attr[:nickname] = params[:nickname] if params[:nickname]
    status = false
    notice = "修改失败。"
    begin
      if user_attr or params[:nickname] or params[:avatar]
        student = Student.find_by_id(params[:student_id].to_i)
        if student
          unless params[:avatar].nil?
            destination_dir = "avatars/students/#{Time.now.strftime('%Y-%m')}"
            rename_file_name = "student_#{student.id}"
            upload = upload_file destination_dir, rename_file_name, params[:avatar]
            url = upload[:url]
          end
          student.user.update_attributes(:name => params[:name]) if params[:name]
          student.user.update_attributes(:avatar_url => url) if params[:avatar]
          student.update_attributes(:nickname => params[:nickname]) if params[:nickname]
          status = true
          notice = "修改成功。"
        else
          notice = "当前学生信息不存在。"          
        end
      else
        notice = "请提交您需要更新的信息。"
      end
    rescue
    end
    render :json => {:status => status, :notice => notice}
  end
  
  #  删除消息
  def delete_posts
    micropost_id = params[:micropost_id]
    micropost = Micropost.find_by_id(micropost_id)
    if micropost&&micropost.destroy
      render :json => {:status => 'success', :notice => '消息删除成功'}
    else
      render :json => {:status => 'error',:notice => '消息删除失败'}
    end
  end
  
  #学生登记个人信息，验证班级code，记录个人信息
  # 1.qq_openid唯一;2班级验证码唯一
  def record_person_info
    #后台测试时代码
    qq_uid = params[:open_id]
    name = params[:name]
    key = params[:key] #激活码
    nickname = params[:nickname]
    avatar = params[:avatar] #上传头像
    verification_code = params[:verification_code]
    student = Student.find_by_qq_uid qq_uid
    school_class = SchoolClass.find_by_verification_code(verification_code)
    if school_class.nil?
      notice = "验证码错误,找不到相关班级!"
      status = "error"
      render :json => {:status => status, :notice => notice}
    else
      if school_class.status == SchoolClass::STATUS[:EXPIRED] ||
          school_class.period_of_validity - Time.now <= 0
        render :json => {:status => "error", :notice => "班级已失效！"}
      else
        flag = "false"
        school = nil
        #如果创建该班级教师属于某个学校的,则减去该学校的配额
        if school_class.teacher.school_id.present?
          school = School.find_by_id school_class.teacher.school_id
          if school.present?
            if school.status == true
              if (school.students_count - school.used_school_counts) >= 1
                flag = "true"
              else
                notice = "配额不足,请联系学校管理员申请学生配额!"
                render :json => {:status => "error", :notice => notice}
              end
            else
              render :json => {:status => "error", :notice => "该学校已被禁用，请联系学校管理员！"}      
            end  
          else
            render :json => {:status => "error", :notice => "信息错误,没有找到该班级所属学校！"}      
          end  
        else
          if key.present?
            notice = "激活码不属于该班级或激活码错误!"
            render :json => {:status => "error_code", :notice => notice}  #error_code
          else
            flag = "none"
          end  
        end
        teacher_status = "false"
        if flag == "none" || flag == "true" 
          if school_class.teacher.status == Teacher::STATUS[:YES]
            teacher_status = "true"
          else
            render :json => {:status => "error", :notice => "创建该班级的教师已被禁用，请联系学校管理员！"}      
          end
        end
        if (flag == "none" && teacher_status == "true") || (flag == "true" && teacher_status == "true")
          active_code = "false"
          if student.nil?
            if key.present? && school.present?
              student = Student.find_by_active_code_and_school_id key, school.id
              if student.nil?
                render :json => {:status => "error_code", :notice => "激活码不属于该班级或激活码错误!"} #error_code
              else
                if student.status == Student::STATUS[:YES]
                  active_code = "true"
                  student.update_attributes(:active_status => Student::ACTIVE_STATUS[:YES])
                else 
                  render :json => {:status => "error", :notice => "该学生已被禁用!"} 
                end  
              end 
            else
              active_code = "none"
            end
            if active_code == "none" || active_code == "true"
                #注释代码为权限控制：控制不是通过激活码注册学生不能加入属于学校管辖的班级
                # student_status = "false"
                if active_code == "true"
                  # student_status = "true"
                  student.update_attributes(:qq_uid => qq_uid)
                elsif active_code == "none"
                  # if school_class.teacher.school_id.present?
                  #   render :json => {:status => "error", :notice => "您没有加入学校的权限！"}      
                  # else  
                  #   student_status = "true"
                    student = Student.create(:nickname => nickname, :qq_uid => qq_uid,
                          :status => Student::STATUS[:YES], :last_visit_class_id => school_class.id)
                      destination_dir = "avatars/students/#{Time.now.strftime('%Y-%m')}"
                      rename_file_name = "student_#{student.id}"
                      avatar_url = ""
                      if !avatar.nil?
                        upload = upload_file destination_dir, rename_file_name, avatar
                        if upload[:status] == true
                          avatar_url = upload[:url]
                        else
                          avatar_url = "/assets/default_avater.jpg"
                        end
                      else
                        avatar_url = "/assets/default_avater.jpg"
                      end
                      user = User.create(:name => name, :avatar_url => avatar_url)
                      student.update_attributes(:user_id => user.id)
                  # end    
                end
                # if student_status == "true"
                  c_s_relation = student.school_class_student_ralastions.
                    where("school_class_id = #{school_class.id} and student_id = #{student.id}")
                  if flag == "true"
                        school.update_attributes(:used_school_counts => school.used_school_counts + 1)
                        SchoolClassStudentsRelation.create(:school_id => school.id, :school_class_id => school_class.id,
                                          :student_id => student.id)
                  end             
                  if !c_s_relation.any?
                    student.school_class_student_ralastions.create(:school_class_id => school_class.id)
                    props = Prop.all
                    props.each do |prop|
                      student.user_prop_relations.create(:prop_id => prop.id, :user_prop_num => Prop::DefaultPropNumber,
                                                         :school_class_id => school_class.id)
                    end  
                    class_id = school_class.id
                    class_name = school_class.name
                    tearcher_id = school_class.teacher.id
                    tearcher_name = school_class.teacher.user.name
                    page = 1
                    microposts = Micropost.get_microposts school_class,page
                    follow_microposts_id = Micropost.get_follows_id microposts, student.user.id
                    render :json => {:status => "success", :notice => "登记成功！",
                      :student => {:id => student.id, :name => student.user.name,:user_id => student.user.id,
                        :nickname => student.nickname, :s_no => student.s_no, :avatar_url => student.user.avatar_url},
                      :class => {:id => class_id, :name => class_name, :tearcher_name => tearcher_name,
                        :tearcher_id => tearcher_id , :period_of_validity => school_class.period_of_validity.strftime("%Y-%m-%d %H:%M:%S")},
                      :microposts => microposts,
                      :follow_microposts_id => follow_microposts_id
                    }
                  else
                    render :json => {:status => "error", :notice => "您已加入该班级,请直接登录！"}               
                  end
                # end  
            end
          else
            render :json => {:status => "error", :notice => "您已注册,请直接登录！"}               
          end
        end      
      end
    end
  end

  #获取同班同学及成就
  def get_classmates_info
    status = "error"
    classmates = nil
    notice = "用户信息错误！"
    student_id = params[:student_id]
    school_class_id = params[:school_class_id]
    student = Student.find_by_id student_id
    school_class = SchoolClass.find_by_id school_class_id
    teacher = Teacher.find_by_id school_class.teacher_id
    teacher_name = nil
    teacher_avatar_url = nil
    if !school_class.nil? && !student.nil? && !teacher.nil?
      classmates = SchoolClass.get_classmates school_class, student.id
      teacher_name = teacher.user.name
      teacher_avatar_url = teacher.user.avatar_url
      notice = "信息获取成功！"
      status = "success"
    end
    render :json => {:status => status, :notice => notice, :teacher_name => teacher_name,
      :teacher_avatar_url => teacher_avatar_url , :classmates => classmates}
  end

  #切换班级
  def get_class_info
    school_class_id = params[:school_class_id]
    student_id = params[:student_id]
    school_class = SchoolClass.find_by_id school_class_id
    student = Student.find_by_id student_id
    if student.nil?
      render :json => {:status => "error", :notice => "用户信息错误！"}
    else
      if !school_class.nil?
        if school_class.id != student.last_visit_class_id
          student.update_attributes(:last_visit_class_id => school_class.id)
        end
        if school_class.status == SchoolClass::STATUS[:EXPIRED] ||
            school_class.period_of_validity - Time.now < 0
          render :json => {:status => "error", :notice => "班级已失效！"}
        else
          school_teacher_status = "false"
          if school_class.teacher.school_id.present?
            school = School.find_by_id school_class.teacher.school_id.to_i          
            if school.present?
              if school.status == true
                if school_class.teacher.status == Teacher::STATUS[:YES] 
                  if student.status == Student::STATUS[:YES]
                    school_teacher_status = "true"
                  else
                    render :json => {:status => "error", :notice => "您的帐号已被禁用，无法获取班级信息！！"}    
                  end  
                else
                  render :json => {:status => "error", :notice => "创建该班级的教师已被禁用,无法获取班级信息！"}  
                end
              else
                render :json => {:status => "error", :notice => "该学校已被禁用，请联系学校管理员！"}
              end  
            else
                render :json => {:status => "error", :notice => "信息错误,没有找到班级所属学校！"}
            end
          else
            if school_class.teacher.status == Teacher::STATUS[:YES] 
              school_teacher_status = "none"
            else
              render :json => {:status => "error", :notice => "创建该班级的教师已被禁用,无法获取班级信息！"}  
            end
          end
          if school_teacher_status == "none" || school_teacher_status == "true"
            class_id = school_class.id
            class_name = school_class.name
            tearcher_id = school_class.teacher.id
            tearcher_name = school_class.teacher.user.name
            page = 1
            microposts = Micropost.get_microposts school_class,page
            follow_microposts_id = Micropost.get_follows_id microposts, student.user.id
            render :json => {:status => "success", :notice => "获取成功！",
              :student => {:id => student.id, :name => student.user.name, :user_id => student.user.id,
                :nickname => student.nickname, :s_no => student.s_no, :avatar_url => student.user.avatar_url},
              :class => {:id => class_id, :name => class_name, :tearcher_name => tearcher_name,
                :tearcher_id => tearcher_id , :period_of_validity => school_class.period_of_validity.strftime("%Y-%m-%d %H:%M:%S")},
              :microposts => microposts,
              :follow_microposts_id => follow_microposts_id,
            }
          end  
        end
      else
        render :json => {:status => "error", :notice => "班级信息错误！"}
      end
    end
  end

  #获取历史答题记录
  def get_answer_history
    student_id = params[:student_id]
    publish_question_package_id = params[:publish_question_package_id]
    student = Student.find_by_id student_id
    publish_question_package = PublishQuestionPackage.find_by_id publish_question_package_id
    status = "error"
    notice = "获取失败！"
    answer_url = nil
    if publish_question_package.present? && student.present?
      s_a_r = StudentAnswerRecord
          .find_by_publish_question_package_id_and_student_id(publish_question_package.id,
                                                              student.id)
      if !s_a_r.nil?
        answer_url = s_a_r.answer_file_url
        status = "success"
        notice = "获取成功！"
      end
    end
    render :json =>  {:status => status, :notice => notice, :answer_url => answer_url}
  end

  #完成某个题包
  def finish_question_packge
    student_id = params[:student_id]
    school_class_id = params[:school_class_id]
    publish_question_package_id = params[:publish_question_package_id]
    answer_file = params[:answer_file]
    student = Student.find_by_id student_id
    school_class = SchoolClass.find_by_id school_class_id
    publish_question_package = PublishQuestionPackage.find_by_id publish_question_package_id
    status = "error"
    notice = "记录失败！"
    updated_time = nil
    knowledges_cards_count = 0
    if !publish_question_package.present?
      notice = "该任务不存在或被删除！"
    else  
      dir_url = student_answer_ques_path(school_class_id, publish_question_package_id)
      rename_file_name = "student_#{student_id}"
      file = upload_file dir_url, rename_file_name, answer_file
      if file[:status] == true
        student_answer_record = StudentAnswerRecord
          .find_by_student_id_and_school_class_id_and_publish_question_package_id(student_id,
          school_class_id,publish_question_package_id)
        if student_answer_record.nil?
          student_answer_record = student.student_answer_records.
            create(:question_package_id => publish_question_package.question_package_id,
            :publish_question_package_id=> publish_question_package.id,
            :status => StudentAnswerRecord::STATUS[:DEALING],
            :school_class_id => school_class.id, :answer_file_url => file[:url])
        else
          student_answer_record.update_attributes(:answer_file_url => file[:url])
        end
        answer_json = ""
        anwser_file_url = "#{Rails.root}/public#{student_answer_record.answer_file_url}"

        File.open(anwser_file_url) do |file|
          file.each do |line|
            answer_json += line.to_s
          end
        end
        answer_records = ActiveSupport::JSON.decode(answer_json)
        PublishQuestionPackage.update_scores_and_achirvements(answer_records, student,
          school_class, publish_question_package, student_answer_record)

        #保存完道具后， 清空文件json中的 道具使用情况，再重新写入文件
        answer_records["props"].each do |prop|
          prop["branch_id"] = []
        end if answer_records["props"]

        File.open(anwser_file_url, "wb"){|f| f.write answer_records.to_json}
        #保存完道具后， 清空文件json中的 道具使用情况
        updated_time = student_answer_record.updated_at.strftime("%Y-%m-%d %H:%M:%S")
        card_bag = CardBag.find_by_school_class_id_and_student_id school_class_id,student_id
        if card_bag.present?
          knowledges_cards_count = card_bag.knowledges_cards_count
        end
        notice = "作业状态更新完成!"
        status = "success"
      else
        notice = "作业状态更新失败,请重新操作!"
        status = "error"
      end
    end  
    render :json => {:status => status, :notice => notice,:updated_time => updated_time, 
                        :knowledges_cards_count => knowledges_cards_count}
  end

  #获取子消息
  def get_reply_microposts
    micropost_id = params[:micropost_id]
    micropost = Micropost.find_by_id micropost_id
    page = params[:page]
    page = 1 if page.nil?
    status = "error"
    if micropost.nil?
      notice = "主消息不存在"
    else
      reply_microposts =  ReplyMicropost.get_microposts micropost.id,page
      if reply_microposts[:pages_count] == 0
        status = "success"
        notice = "暂无子消息!"
      else
        status = "success"    #test
        notice = "获取完成!"
      end
    end
    render :json => {:status => status, :notice => notice, :reply_microposts => reply_microposts}
  end

  #加入新班级
  def validate_verification_code
    verification_code = params[:verification_code]
    student_id = params[:student_id]

    student = Student.find_by_id student_id
    if student.nil?
      status = "error"
      notice = "学生信息错误，请重新登陆！"
      render :json => {:status => status, :notice => notice}
    else
      school_class = SchoolClass.find_by_verification_code verification_code
      if !school_class.nil?
        if school_class.status == SchoolClass::STATUS[:EXPIRED] ||
            school_class.period_of_validity - Time.now < 0
          render :json => {:status => "error", :notice => "班级已失效！"}
        else
          flag = "false"
          #如果创建该班级教师属于某个学校的,则减去该学校的配额
          if school_class.teacher.school_id.present?
            school = School.find_by_id school_class.teacher.school_id
            if student.school_id.present? && student.school_id != school.id
              notice = "一个学生只能加入一个学校!"
              status = "error"
              render :json => {:status => status, :notice => notice}  
            else
              if school && (school.students_count - school.used_school_counts) >= 1
                flag = "true"
              else
                notice = "配额不足,请联系学校管理员申请学生配额!"
                status = "error"
                render :json => {:status => status, :notice => notice}
              end  
            end  
          else
            flag = "none"
          end
          if flag == "true" || flag == "none"
            school_class_student_relations = SchoolClassStudentRalastion
              .find_by_school_class_id_and_student_id school_class.id, student.id
            if school_class_student_relations.nil?
              c_s_relation = student.school_class_student_ralastions
              if c_s_relation && c_s_relation.any?
                my_school_classes_id = c_s_relation.map(&:school_class_id)  
              end
              school_class_student_relations = student.school_class_student_ralastions.
                create(:school_class_id => school_class.id)

              props = Prop.all
              props.each do |prop|
                student.user_prop_relations.create(:prop_id => prop.id, :user_prop_num => Prop::DefaultPropNumber,
                                                   :school_class_id => school_class.id)
              end
              if flag == "true"
                school.update_attributes(:used_school_counts => school.used_school_counts + 1)
                  SchoolClassStudentsRelation.create(:school_id => school.id, :school_class_id => school_class.id,
                                  :student_id => student.id)
              end   
              class_id = school_class.id
              class_name = school_class.name
              tearcher_id = school_class.teacher.id
              tearcher_name = school_class.teacher.user.name
              page = 1
              microposts = Micropost.get_microposts school_class,page
              follow_microposts_id = Micropost.get_follows_id microposts, student.user.id
              render :json => {:status => "success", :notice => "验证成功！",
                :student => {:id => student.id, :name => student.user.name, :user_id => student.user.id,
                  :nickname => student.nickname, :s_no => student.s_no, :avatar_url => student.user.avatar_url},
                :class => {:id => class_id, :name => class_name, :tearcher_name => tearcher_name,
                  :tearcher_id => tearcher_id, :period_of_validity => school_class.period_of_validity.strftime("%Y-%m-%d %H:%M:%S") },
                :microposts => microposts,
                :follow_microposts_id => follow_microposts_id,
              }
            else
              status = "error"
              notice = "您已加入该班级!"
              render :json => {:status => status, :notice => notice}  
            end
          end  
        end
      else
        status = "error"
        notice = "班级验证码错误！"
        render :json => {:status => status, :notice => notice}
      end
    end
  end

  #删除子消息
  def delete_reply_microposts
    reply_micropost_id = params[:reply_micropost_id]
    #sender_id = params[:sender_id]
    #sender_types = params[:sender_id]
    status = "error"
    notice = "删除失败!"
    reply_micropost =  ReplyMicropost.find_by_id reply_micropost_id
    if !reply_micropost.nil?
      if reply_micropost.destroy
        status = "success"
        notice = "删除成功!"
      end
    end
    render :json => {:status => status, :notice => notice}
  end

  #获取我的成就
  def get_my_archivements
    student_id = params[:student_id].to_i
    school_class_id = params[:school_class_id].to_i
    notice = "用户信息错误!"
    status = "error"
    archivements = nil
    student = Student.find_by_id student_id
    school_class = SchoolClass.find_by_id school_class_id
    school_class_student_relation = SchoolClassStudentRalastion
    .find_by_school_class_id_and_student_id school_class_id, student_id
    if !student.nil? && !school_class.nil? && !school_class_student_relation.nil?
      archivements = ArchivementsRecord.where("school_class_id = ? and student_id = ?",school_class.id, student.id )
      .select("student_id, school_class_id, archivement_score, archivement_types")
      notice = "加载完成!"
      status = "success"
    end
    render :json => {:status => status, :notice => notice, :archivements => archivements}
  end

  #获取我的提示消息
  def get_messages
    user_id = params[:user_id]
    school_class_id = params[:school_class_id]
    page = params[:page]
    user = User.find_by_id user_id
    school_class = SchoolClass.find_by_id school_class_id
    student = user.student if !user.nil?
    if user.nil? || school_class.nil?
      notice = "用户信息错误!"
      status = "error"
    else
      if student.nil?
        notice = "用户信息错误!"
        status = "error"
      else
        school_class_student_relations = SchoolClassStudentRalastion.
          find_by_student_id_and_school_class_id student.id, school_class.id
        if school_class_student_relations.nil?
          notice = "用户信息错误!"
          status = "error"
        else
          messages = Message.get_mine_messages school_class, user_id,page
          if messages.length == 0
            status = "success"
            notice = "暂无消息!"
          else
            status = "success"
            notice = "获取完成!"
          end
        end
      end
    end
    render :json => {:status => status, :notice => notice, :messages => messages}
  end

  #获取教师的提示消息
  def get_teacher_messages
    user_id = params[:user_id].to_i
    school_class_id = params[:school_class_id].to_i
    user = User.find_by_id user_id
    school_class = SchoolClass.find_by_id school_class_id
    teacher = user.teacher if !user.nil?
    if user.nil? || school_class.nil?
      notice = "用户信息错误!"
      status = "error"
    else
      if teacher.nil?
        notice = "用户信息错误!"
        status = "error"
      else
        if user_id != 0
          messages = Message.get_my_messages school_class, user_id
          if messages.length == 0
            status = "success"
            notice = "暂无消息!"
          else
            status = "success"
            notice = "获取完成!"
          end
        else
          status = "error"
          notice = "参数错误!"
        end
      end
    end
    render :json => {:status => status, :notice => notice, :messages => messages}
  end

  #阅读我的提示消息
  def read_message
    user_id = params[:user_id]
    school_class_id = params[:school_class_id]
    message_id = params[:message_id]
    user = User.find_by_id user_id
    school_class = SchoolClass.find_by_id school_class_id
    student = user.student.nil? ? nil : user.student
    message = Message.find_by_id message_id
    micropost = nil
    notice = "查看失败！"
    status = "error"
    if user.nil? || school_class.nil?
      notice = "用户或班级信息有误，请重新登陆！"
    else
      if student.nil?
        notice = "学生信息有误，请重新登陆！"
      else
        school_class_student_relations = SchoolClassStudentRalastion.
          find_by_student_id_and_school_class_id student.id, school_class.id
        if school_class_student_relations.nil?
          notice = "该学生不属于该班级！"
        else
          if message.nil?
            notice = "该提示消息不存在！"
          else
            if message.update_attributes(:status => Message::STATUS[:READED])
              sql_str = "select m.content, DATE_FORMAT(m.created_at, '%Y-%m-%d %H:%i:%S') as new_created_at, m.id micropost_id, m.reply_microposts_count,
              m.school_class_id, m.user_id,m.user_types, u.name, u.avatar_url from microposts m
              left join users u on m.user_id = u.id where m.id = #{message.micropost_id}"
              micropost = Message.find_by_sql sql_str
              if micropost.nil?
                notice = "主消息不存在！"
              else
                status = "success"
                notice = "已阅读！"
              end
            else
              notice = "查看失败！"
            end
          end
        end
      end
    end
    render :json => {:status => status, :notice => notice, :micropost =>  micropost}
  end

  #删除提示消息
  def delete_message
    user_id = params[:user_id]
    school_class_id = params[:school_class_id]
    message_id = params[:message_id]
    message = Message.find_by_id message_id
    info = is_delete_message user_id, school_class_id, message
    render :json => info
  end
  #删除系统通知
  def delete_sys_message
    user_id = params[:user_id]
    school_class_id = params[:school_class_id]
    sys_message_id = params[:sys_message_id]
    message = SysMessage.find_by_id sys_message_id
    info = is_delete_message user_id, school_class_id, message
    render :json => info
  end
  #获取系统通知的内容
  def get_sys_message
    student_id = params[:student_id]
    school_class_id = params[:school_class_id]
    student = Student.find_by_id student_id
    if student.blank?
      status = "error"
      notice = "用户不存在"
      sysmessage = nil
    else
      page = params[:page].nil? ? 1 : params[:page]
      sysmessage = SysMessage.paginate_by_sql(["select DATE_FORMAT(sm.created_at, '%Y-%m-%d %H:%i:%S') as new_created_at, sm.id, sm.status, sm.school_class_id, sm.student_id,sm.content from sys_messages sm WHERE student_id = ? and school_class_id = ? order by created_at desc",
          student_id,school_class_id],:per_page =>SysMessage::PER_PAGE ,:page => page)
      status = "success"
      notice = "获取成功！！"
    end
    render :json => {:status => status,:notice => notice,:sysmessage => sysmessage }
  end
  #列出卡包所有卡片的列表#根据分类查询列出卡包卡片的列表api
  def get_knowledges_card
    student_id = params[:student_id].to_i
    school_class_id = params[:school_class_id].to_i
    mistake_types = params[:mistake_types]
    info = knowledges_card_list student_id,school_class_id,mistake_types
    render :json => info
  end
  #删除卡片api
  def delete_knowledges_card
    knowledges_card_id = params[:knowledges_card_id]
    knowledges_card = KnowledgesCard.find_by_id knowledges_card_id
    status = "error"
    notice = "删除失败!"
    if knowledges_card && knowledges_card.destroy
      status = "success"
      notice = "删除成功!"
    end
    render :json => {:status => status,:notice => notice}
  end

  #  新建标签并且加入知识卡片
  def create_card_tag
    knowledge_card_id = params[:knowledge_card_id]
    name = params[:name]
    school_class_id = params[:school_class_id]
    student_id = params[:student_id]
    cardbag = CardBag.find_by_school_class_id_and_student_id school_class_id,student_id
    cardtag = nil
    if cardbag
      cardbag_id = cardbag.id
      card_tag = CardTag.find_by_name_and_card_bag_id name,cardbag_id
      if card_tag
        cardtagknowledgescardrelation = CardTagKnowledgesCardRelation.find_by_knowledges_card_id_and_card_tag_id knowledge_card_id,card_tag.id
        if cardtagknowledgescardrelation
          status = "error"
          notice = "知识卡片已存在"
        else
          cardtagknowledgescardrelation = CardTagKnowledgesCardRelation.new(:knowledges_card_id => knowledge_card_id,:card_tag_id => card_tag.id)
          if cardtagknowledgescardrelation.save
            status = "success"
            notice = "添加成功"
          else
            status = "error"
            notice = "添加失败"
          end
        end
      else
        CardTag.transaction do
          cardtag = CardTag.create(:name =>name,:card_bag_id => cardbag_id)
          CardTagKnowledgesCardRelation.create(:knowledges_card_id => knowledge_card_id,:card_tag_id => cardtag.id)
        end
        status = "success"
        notice = "添加成功"
      end
    else
      status = "error"
      notice = "标签创建失败"
    end
    render :json => {:status => status,:notice => notice,:cardtag => cardtag}
  end
  #添加或者取消进标签
  def knoledge_tag_relation
    knowledge_card_id = params[:knowledge_card_id]
    school_class_id = params[:school_class_id]
    student_id = params[:student_id]
    card_tag_id = params[:card_tag_id]
    cardbag = CardBag.find_by_school_class_id_and_student_id school_class_id,student_id
    if cardbag
      cardtagknowledgescardrelation = CardTagKnowledgesCardRelation.find_by_knowledges_card_id_and_card_tag_id knowledge_card_id,card_tag_id
      if cardtagknowledgescardrelation
        cardtagknowledgescardrelation.destroy
        status = "success"
        type = 1
        notice = "已移除"
      else
        cardtagknowledgescardrelation = CardTagKnowledgesCardRelation.new(:knowledges_card_id => knowledge_card_id,:card_tag_id => card_tag_id)
        if cardtagknowledgescardrelation.save
          status = "success"
          notice = "添加成功"
          type = 2
        else
          status = "error"
          notice = "添加失败"
          type = 0
        end
      end
    else
      status = "error"
      notice = "卡包不存在！"
      type = 0
    end
    render :json => {:status => status,:notice => notice,:type=>type}
  end
  #  搜索标签下的卡片
  def search_tag_card
    name = params[:name].nil? ?  "%%" : '%'+ params[:name].strip + '%'
    school_class_id = params[:school_class_id]
    student_id = params[:student_id]
    page = params[:page].nil? ? 1 : params[:page].to_i
    info = knowledges_andcards_tolist school_class_id,student_id,name
    render :json =>info
  end

  #返回新任务的id
  def new_homework
    school_class_id = params[:school_class_id].to_i
    student_id = params[:student_id].to_i
    num = 0
    pq_packages = PublishQuestionPackage.find_by_sql(["select id from publish_question_packages
      where status = ? and end_time >= ? and school_class_id = ? ", PublishQuestionPackage::STATUS[:NEW],
        Time.now(), school_class_id])
    pq_packages.map!(&:id)
    if pq_packages.any?
      s_a_records = StudentAnswerRecord.find_by_sql(["select publish_question_package_id id from student_answer_records
        where student_id = ? and publish_question_package_id in (?)", student_id, pq_packages])
      s_a_records.map!(&:id)
      new_id = s_a_records.any? ? pq_packages-s_a_records : pq_packages
    else
      new_id = []
    end
    render :json => {:new_id => new_id}
  end
  
  #返回当前app版本
  def current_version
    c_version = AppVersion.select("max(c_version) current_version")[0]
    render :json => c_version
  end

  #获取某个任务的某种题型的排行情况
  def get_rankings
    pub_id = params[:pub_id]
    question_types = params[:types]
    status = "error"
    notice = "获取出错！"
    record_details = nil
    if !pub_id.nil? && !question_types.nil?
      record_details = StudentAnswerRecord
      .joins("left join students s on student_answer_records.student_id = s.id")
      .joins("left join record_details rd on student_answer_records.id =
            rd.student_answer_record_id")
      .joins("left join users u on s.user_id = u.id")
      .select("student_answer_records.student_id, u.name, u.avatar_url, rd.score")
      .where(["publish_question_package_id = ? and rd.question_types = ?", pub_id.to_i, question_types.to_i])
      .order("rd.score desc, rd.updated_at asc, rd.created_at asc").offset(0).limit(10)
      status = "success"
      if record_details.length == 0
        notice = "暂无排行数据！"
      else
        notice = "获取完成！"
      end
    end
    render :json => {:status => status, :notice => notice, :record_details => record_details}
  end
end
