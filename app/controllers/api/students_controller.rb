#encoding: utf-8
require 'rexml/document'
include REXML
class Api::StudentsController < ApplicationController
  #  发布消息
  def news_release
    content = params[:content]
    user_id = params[:user_id]
    user_types = params[:user_types]
    school_class_id = params[:school_class_id]
    micropost = Micropost.new(:user_id => user_id, :user_types => user_types, :content => content, :school_class_id => school_class_id)
    if micropost.save
      render :json => {:status => 'success', :notice => '消息发布成功'}
    else
      render :json => {:status => 'error', :notice => '消息发布失败'}
    end
  end
  #  回复消息
  def reply_message
    sender_id = params[:sender_id]
    sender_types = params[:sender_types]
    content = params[:content]
    micropost_id = params[:micropost_id]
    reciver_id = params[:reciver_id]
    reciver_types = params[:reciver_types]
    replymicropost = ReplyMicropost.new(:sender_id => sender_id, :sender_types => sender_types, :content => content,
      :micropost_id => micropost_id, :reciver_id => reciver_id,:reciver_types => reciver_types)
    if replymicropost.save
      render :json => {:status => 'success', :notice => '消息回复成功'}
    else
      render :json => {:status => 'error', :notice => '消息回复失败'}
    end
  end
  #  关注消息api
  def add_concern
    student_id = params[:student_id].to_i
    micropost_id = params[:micropost_id].to_i
    followmicropost = FollowMicropost.new(:student_id => student_id, :micropost_id => micropost_id)
    if followmicropost.save
      render :json => {:status => 'success', :notice => '关注添加成功'}
    else
      render :json => {:status => 'error', :notice => '关注添加失败'}
    end
  end
  #  取消关注
  def unfollow
    student_id = params[:student_id].to_i
    micropost_id = params[:micropost_id].to_i
    followmicropost_exits = FollowMicropost.find_by_student_id_and_micropost_id(student_id,micropost_id)
    if followmicropost_exits && followmicropost_exits.destroy
      render :json => {:status => 'success', :notice => '取消关注成功'}
    else
      render :json => {:status => 'error', :notice => '取消关注失败'}
    end
  end
  #切换班级
  def get_my_classes
    student_id = params[:student_id].to_i
    classes = SchoolClass.find_by_sql("SELECT school_classes.id class_id,school_classes.name class_name
from school_classes INNER JOIN school_class_student_ralastions on school_classes.id = school_class_student_ralastions.class_id
and school_class_student_ralastions.student_id =#{student_id} and school_classes.status = #{SchoolClass::STATUS[:NORMAL]}")
    render :json => {:classes => classes}
  end

  #qq登陆
  def login
    qq_uid = params[:qq_uid]
    student = Student.find_by_qq_uid qq_uid
    if student.nil?
      render :json => {:status => "error", :notice => "账号不存在，请注册！"}
    else
      school_class = SchoolClass.find_by_id student.last_visit_class_id
      class_id = nil
      class_name = nil
      tearcher_name = nil
      tearcher_id = nil
      classmates = nil
      task_messages = nil
      microposts = nil
      daily_tasks = nil
      if !school_class.nil?
        class_id = school_class.id
        class_name = school_class.name
        tearcher_id = school_class.teacher.id
        tearcher_name = school_class.teacher.name
        classmates = SchoolClass.get_classmates school_class
        task_messages = TaskMessage.get_task_messages school_class.id
        page = 1
        microposts = Micropost.get_microposts school_class,page
        daily_tasks = StudentAnswerRecord.get_daily_tasks school_class.id, student.id
      end
      render :json => {:status => "success", :notice => "登陆成功！",
        :student => {:id => student.id, :name => student.name,
          :nickname => student.nickname, :avatar_url => student.avatar_url},
        :class => {:id => class_id, :name => class_name, :tearcher_name => tearcher_name,
          :tearcher_id => tearcher_name },
        :classmates => classmates
      }
    end
  end
  #  点击每日任务获取题包
  def into_daily_tasks
    student_id = params[:student_id]
    publish_question_package_id = params[:publish_question_package_id]
    studentanswerrecord = StudentAnswerRecord.find_by_student_id_and_publish_question_package_id(student_id,publish_question_package_id)
#    p studentanswerrecord
#    p 111111
#    p studentanswerrecord.id
#    answer_file_url = studentanswerrecord.answer_file_url
    #    student = Student.find_by_id(student_id)
    #   answer_file_url = student.answer_file_url
    #    school_class_id = params[:school_class_id].to_i
    #    types = params[:types].to_i
    #    file = File.new("#{Rails.root}/public/question_package_1.xml")
    #    file = IO.readlines("#{Rails.root}/public/question_package_1.xml")
    question_records = ''
    File.open("#{Rails.root}/public/question_package_1.xml") do |file|
      file.each do |line|
        question_records += line
      end
    end
    already_done = Hash.from_xml(question_records)
    render :json =>  already_done ? already_done : "题目没做"
  end

  #获取消息microposts(分页)
  def get_microposts
    school_class_id = params[:school_class_id]
    student_id = params[:student_id]
    page = params[:page]
    school_class = SchoolClass.find_by_id school_class_id
    student = Student.find_by_id student_id
    microposts = nil
    status = "error"
    if student.nil?
      status = "error"
      notice = "学生信息错误"
    else
      if school_class.nil?

        notice = "班级不存在"
      else
        school_class_student_relations = SchoolClassStudentRalastion.find_by_school_class_id_and_student_id school_class.id, student.id
        if school_class_student_relations.nil?
          status = "success"
          notice = "加载完成"

        else
          if school_class.status == SchoolClass::STATUS[:NORMAL]
            if page.nil?
              status = "error"
              notice = "页数为空"
              microposts = nil
            else
              status = "success"
              notice = "加载完成"
              microposts = Micropost.get_microposts school_class,page
            end
          else
            status = "error"
            notice = "班级已过期"
            microposts = nil
          end
        end
      end
    end
    render :json => {:status => status, :notice => notice,:microposts => microposts}
  end
  #  更新个人信息
  def modify_person_info
    student_id = params[:student_id].to_i
    student = Student.find_by_id(student_id)
    #    FileUtils.mkdir_p "#{File.expand_path(Rails.root)}/public/student_img/#{student_id}" if !(File.exist?("#{File.expand_path(Rails.root)}/public/student_img/#{student_id}"))
    #    picture = params[:picture]
    #    filename = picture.original_filename
    #    fileext = File.basename(filename).split(".")[1]
    #    timeext =  "avatar" + student_id.to_s
    #    newfilename = timeext+"."+fileext
    #    avatar_url = "#{Rails.root}/public/student_img/#{student_id}/#{newfilename}"
    #    File.open("#{Rails.root}/public/student_img/#{student_id}/#{newfilename}","wb") {
    #      |f| f.write(picture.read)
    #    }
    name = params[:name]
    nickname = params[:nickname]
    if student.update_attributes(:name => name, :nickname => nickname)
      render :json => {:status => 'success',:notice => '修改成功'}
    else
      render :json => {:status => 'error',:notice => '修改失败'}
    end
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
    qq_uid = params[:qq_uid]
    name = params[:name]
    nickname = params[:nickname]
    verification_code = params[:verification_code]
    student = Student.find_by_qq_uid qq_uid
    class_id = nil
    class_name = nil
    tearcher_name = nil
    tearcher_id = nil
    classmates = nil
    task_messages = nil
    microposts = nil
    daily_tasks = nil
    if student.nil?
      school_class = SchoolClass.find_by_verification_code(verification_code)
      if !school_class.nil?
        begin
          student = Student.create(:name => name, :nickname => nickname, :qq_uid => qq_uid,
            :last_visit_class_id => school_class.id)
          student.school_class_student_ralastions.create(:school_class_id => school_class.id)
        rescue
          notice = "qq账号已经注册,请直接登陆"
          status = "error"
          render :json => {:status => status, :notice => notice}
        end
        class_id = school_class.id
        class_name = school_class.name
        tearcher_id = school_class.teacher.id
        tearcher_name = school_class.teacher.name
        classmates = SchoolClass.get_classmates school_class
        task_messages = TaskMessage.get_task_messages school_class.id
        page = 1
        microposts = Micropost.get_microposts school_class,page
        daily_tasks = StudentAnswerRecord.get_daily_tasks school_class.id, student.id
        render :json => {:status => "success", :notice => "登记完成！",
          :student => {:id => student.id, :name => student.name,
            :nickname => student.nickname, :avatar_url => student.avatar_url},
          :class => {:id => class_id, :name => class_name, :tearcher_name => tearcher_name,
            :tearcher_id => tearcher_id },
          :classmates => classmates,
          :task_messages => task_messages,
          :microposts => microposts,
          :daily_tasks => daily_tasks
        }
      else
        notice = "验证码错误,找不到相关班级!"
        status = "error"
        render :json => {:status => status, :notice => notice}
      end
    else
      notice = "qq账号已经存在,请直接登陆"
      status = "error"
      render :json => {:status => status, :notice => notice}
    end
  end

  #获取页面信息
  def get_class_info
    school_class_id = params[:school_class_id]
    student_id = params[:student_id]
    school_class = SchoolClass.find_by_id school_class_id
    student = Student.find_by_id student_id
    if student.nil?
      render :json => {:status => "error", :notice => "用户信息错误！"}
    else
      school_class = SchoolClass.find_by_id student.last_visit_class_id
      class_id = nil
      class_name = nil
      tearcher_name = nil
      tearcher_id = nil
      classmates = nil
      task_messages = nil
      microposts = nil
      daily_tasks = nil
      if !school_class.nil?
        class_id = school_class.id
        class_name = school_class.name
        tearcher_id = school_class.teacher.id
        tearcher_name = school_class.teacher.name
        classmates = SchoolClass.get_classmates school_class
        task_messages = TaskMessage.get_task_messages school_class.id
        page = 1
        microposts = Micropost.get_microposts school_class,page
        daily_tasks = StudentAnswerRecord.get_daily_tasks school_class.id, student.id
      else
        render :json => {:status => "error", :notice => "班级信息错误！"}
      end
      render :json => {:status => "success", :notice => "登陆成功！",
        :student => {:id => student.id, :name => student.name,
          :nickname => student.nickname, :avatar_url => student.avatar_url},
        :class => {:id => class_id, :name => class_name, :tearcher_name => tearcher_name,
          :tearcher_id => tearcher_id },
        :classmates => classmates,
        :task_messages => task_messages,
        :microposts => microposts,
        :daily_tasks => daily_tasks
      }
    end
  end
end
