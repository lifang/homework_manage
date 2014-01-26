#encoding: utf-8
require 'xml_to_json/string'
require 'rexml/document'
include REXML
require 'json'
include MethodLibsHelper
class Api::StudentsController < ApplicationController
  #  发布消息
  def news_release
    content = params[:content] 
    user_id = params[:user_id]
    user_types = params[:user_types]
    school_class_id = params[:school_class_id]
    micropost = Micropost.new(:user_id => user_id, :user_types => user_types, 
      :content => content, :school_class_id => school_class_id, :reply_microposts_count => 0)
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
    content = params[:content].strip
    micropost_id = params[:micropost_id]
    reciver_id = params[:reciver_id]
    reciver_types = params[:reciver_types]
    school_class_id = params[:school_class_id]
    micropost = Micropost.find_by_id micropost_id.to_i    
    if micropost
      Message.add_messages(micropost_id, reciver_id, reciver_types, sender_id, sender_types, 
        content, school_class_id)
      replymicropost = ReplyMicropost.new(:sender_id => sender_id, 
      :sender_types => sender_types, :content => content,
      :micropost_id => micropost_id, :reciver_id => reciver_id,:reciver_types => reciver_types)
      replymicropost.save
      micropost.update_attributes(:reply_microposts_count => (micropost.reply_microposts_count + 1))
      render :json => {:status => 'success', :notice => '消息回复成功'}
    else
      render :json => {:status => 'error', :notice => '消息回复失败'}
    end    
  end
  
  #  关注消息api
  def add_concern
    user_id = params[:user_id].to_i
    micropost_id = params[:micropost_id].to_i
    followmicropost = FollowMicropost.new(:user_id => user_id, :micropost_id => micropost_id)
    if followmicropost.save
      render :json => {:status => 'success', :notice => '关注添加成功'}
    else
      render :json => {:status => 'error', :notice => '关注添加失败'}
    end
  end
  #  取消关注
  def unfollow
    user_id = params[:user_id].to_i
    micropost_id = params[:micropost_id].to_i
    followmicropost_exits = FollowMicropost.find_by_user_id_and_micropost_id(user_id, micropost_id)
    if followmicropost_exits && followmicropost_exits.destroy
      render :json => {:status => 'success', :notice => '取消关注成功'}
    else
      render :json => {:status => 'error', :notice => '取消关注失败'}
    end
  end
  #切换班级
  def get_my_classes
    student_id = params[:student_id].to_i
    classes = SchoolClass.find_by_sql(["SELECT school_classes.id class_id,school_classes.name class_name
            from school_classes INNER JOIN school_class_student_ralastions 
            on school_classes.id = school_class_student_ralastions.school_class_id
            where school_classes.status = ? and school_classes.period_of_validity >= ?
            and school_class_student_ralastions.student_id = ?", 
            SchoolClass::STATUS[:NORMAL], Time.now(), student_id])
    render :json => {:classes => classes}
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

  #qq登陆
  def login
    qq_uid = params[:open_id]
    student = Student.find_by_qq_uid qq_uid
    if student.nil?
      render :json => {:status => "error", :notice => "账号不存在，请先注册！"}
    else
      school_class = SchoolClass.find_by_id student.last_visit_class_id
      if !school_class.nil?
        if school_class.status == SchoolClass::STATUS[:EXPIRED] ||
            school_class.period_of_validity - Time.now < 0
          school_class = student.school_classes.where("status != #{SchoolClass::STATUS[:EXPIRED]}")[0]
        end
        if !school_class.nil?
          class_id = school_class.id
          class_name = school_class.name
          tearcher_id = school_class.teacher.id
          tearcher_name = school_class.teacher.user.name
          classmates = SchoolClass.get_classmates school_class
          task_messages = TaskMessage.get_task_messages school_class.id
          page = 1
          microposts = Micropost.get_microposts school_class,page
          follow_microposts_id = Micropost.get_follows_id microposts, student.user.id
          daily_tasks = StudentAnswerRecord.get_daily_tasks school_class.id, student.id
          messages = Message.get_my_messages school_class, student.user.id
          render :json => {:status => "success", :notice => "登陆成功！",
                           :student => {:id => student.id, :name => student.user.name, :user_id => student.user.id,
                                        :nickname => student.nickname, :avatar_url => student.user.avatar_url},
                           :class => {:id => class_id, :name => class_name, :tearcher_name => tearcher_name,
                                      :tearcher_id => tearcher_id },
                           :classmates => classmates,
                           :task_messages => task_messages,
                           :microposts => microposts,
                           :daily_tasks => daily_tasks,
                           :follow_microposts_id => follow_microposts_id,
                           :messages => messages
          }
        else
          render :json => {:status => "error", :notice => "班级已失效,请重新登记信息！"}
        end
      else
        render :json => {:status => "error", :notice => "班级不存在！"}
      end
    end
  end
  #  点击每日任务获取题包
  def into_daily_tasks
    student_id = params[:student_id]
    p_q_package_id = params[:publish_question_package_id]
    p_q_package = PublishQuestionPackage.find_by_id p_q_package_id.to_i
    package_json = ""
    answer_json = ""
    status = false
    if p_q_package
      begin
        package_json = File.open("#{Rails.root}/public#{p_q_package.question_packages_url}").read if p_q_package and p_q_package.question_packages_url
        status = true
        s_a_record = StudentAnswerRecord.find_by_student_id_and_publish_question_package_id(student_id, p_q_package_id)
        if s_a_record
          answer_json = File.open("#{Rails.root}/public#{s_a_record.answer_file_url}").read if s_a_record and s_a_record.answer_file_url
        end
      rescue
        notice = "文件加载错误，请稍后重试。"
      end
    end
    notice = status == false ? "没有作业内容。" : ""
    render :json => {:status => status, :notice => notice, 
      :package => (package_json.empty? ? "" : ActiveSupport::JSON.decode(package_json)), 
      :user_answers => (answer_json.empty? ? "" : ActiveSupport::JSON.decode(answer_json))}
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
          status = "success"
          notice = "加载完成"

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
            destination_dir = "homework_system/avatars/students/#{Time.now.strftime('%Y-%m')}"
            rename_file_name = "student_#{student.id}"
            upload = upload_file destination_dir, rename_file_name, params[:avatar]
            url = upload[:url]
            unuse_url = "#{Rails.root}/public"
            avatar_url = url.to_s[unuse_url.size,url.size]
            user_attr[:avatar_url] = avatar_url
          end
          student.user.update_attributes(user_attr) if user_attr
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
    #file = ""
    #params.each_with_index do |e,index|
    #  file = e[1]  if index == 0
    #end
    qq_uid = params[:open_id]
    name = params[:name]
    nickname = params[:nickname]
    file = params[:avatar] #上传头像
    verification_code = params[:verification_code]
    student = Student.find_by_qq_uid qq_uid
    if student.nil?
      school_class = SchoolClass.find_by_verification_code(verification_code)
      if !school_class.nil?
        if school_class.status == SchoolClass::STATUS[:EXPIRED] ||
            school_class.period_of_validity - Time.now <= 0
          p school_class.period_of_validity - Time.now
          render :json => {:status => "error", :notice => "班级已失效！"}
        else
          Student.transaction do
              student = Student.create(:nickname => nickname, :qq_uid => qq_uid,
                  :status => Student::STATUS[:YES],
                  :last_visit_class_id => school_class.id)
              destination_dir = "avatars/students/#{Time.now.strftime('%Y-%m')}"
              rename_file_name = "student_#{student.id}"
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
              student.update_attributes(:user_id => user.id)
              student.school_class_student_ralastions.create(:school_class_id => school_class.id)
              class_id = school_class.id
              class_name = school_class.name
              tearcher_id = school_class.teacher.id
              tearcher_name = school_class.teacher.user.name
              classmates = SchoolClass.get_classmates school_class, student.id
              task_messages = TaskMessage.get_task_messages school_class.id
              page = 1
              microposts = Micropost.get_microposts school_class,page
              follow_microposts_id = Micropost.get_follows_id microposts, student.user.id
              daily_tasks = StudentAnswerRecord.get_daily_tasks school_class.id, student.id
              messages = Message.get_my_messages school_class, student.user.id
              render :json => {:status => "success", :notice => "登记成功！",
                               :student => {:id => student.id, :name => student.user.name,:user_id => student.user.id,
                                            :nickname => student.nickname, :avatar_url => student.user.avatar_url},
                               :class => {:id => class_id, :name => class_name, :tearcher_name => tearcher_name,
                                          :tearcher_id => tearcher_id },
                               :classmates => classmates,
                               :task_messages => task_messages,
                               :microposts => microposts,
                               :daily_tasks => daily_tasks,
                               :follow_microposts_id => follow_microposts_id,
                               :messages => messages
              }
          end
        end
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
      if !school_class.nil?
        if school_class.id != student.last_visit_class_id
          student.update_attributes(:last_visit_class_id => school_class.id)
        end
        if school_class.status == SchoolClass::STATUS[:EXPIRED] ||
            school_class.period_of_validity - Time.now < 0
          render :json => {:status => "error", :notice => "班级已失效！"}
        else
          class_id = school_class.id
          class_name = school_class.name
          tearcher_id = school_class.teacher.id
          tearcher_name = school_class.teacher.user.name
          classmates = SchoolClass.get_classmates school_class
          task_messages = TaskMessage.get_task_messages school_class.id
          page = 1
          microposts = Micropost.get_microposts school_class,page
          follow_microposts_id = Micropost.get_follows_id microposts, student.user.id
          daily_tasks = StudentAnswerRecord.get_daily_tasks school_class.id, student.id
          messages = Message.get_my_messages school_class, student.user.id
          render :json => {:status => "success", :notice => "登陆成功！",
                           :student => {:id => student.id, :name => student.user.name, :user_id => student.user.id,
                                        :nickname => student.nickname, :avatar_url => student.user.avatar_url},
                           :class => {:id => class_id, :name => class_name, :tearcher_name => tearcher_name,
                                      :tearcher_id => tearcher_id },
                           :classmates => classmates,
                           :task_messages => task_messages,
                           :microposts => microposts,
                           :daily_tasks => daily_tasks,
                           :follow_microposts_id => follow_microposts_id,
                           :messages => messages
          }
        end
      else
        render :json => {:status => "error", :notice => "班级信息错误！"}
      end
    end
  end

  #记录答题信息
  def record_answer_info
    student_id = params[:student_id]
    school_class_id = params[:school_class_id]
    publish_question_package_id = params[:publish_question_package_id]
    question_id = params[:question_id]
    branch_question_id = params[:branch_question_id]
    answer = params[:answer]
    question_types = params[:question_types].to_i  #题型:听力或朗读
    student = Student.find_by_id student_id
    school_class = SchoolClass.find_by_id school_class_id
    publish_question_package = PublishQuestionPackage.find_by_id publish_question_package_id
    student_answer_record = nil
    status = "error"
    notice = "记录失败！"

    if !publish_question_package.nil?
      url = "/"
      count = 0
      if !student.nil?
        questions_xml_dir = "pub_que_ps/pub_#{publish_question_package.id}/answers"
        answer_file_full_name = "student_#{student.id}.js"
        if !school_class.nil?
          school_class_student_relation = SchoolClassStudentRalastion.
              find_all_by_school_class_id_and_student_id school_class.id, student.id
          if school_class_student_relation.nil?
            notice = "该学生不属于当前班级,操作失败!"
          else
            p student.id
            p publish_question_package.id
            student_answer_record = StudentAnswerRecord.
                find_by_student_id_and_publish_question_package_id student.id, publish_question_package.id
            if student_answer_record.nil?
              if !publish_question_package.question_package.nil?
              student_answer_record = student.student_answer_records.
                  create(:question_package_id => publish_question_package.question_package.id,
                         :publish_question_package_id=> publish_question_package.id,
                         :status => StudentAnswerRecord::STATUS[:DEALING],
                         :school_class_id => school_class.id,
                        :listening_answer_count => 0 , :reading_answer_count => 0)
              end
            end
            if !student_answer_record.nil?
              info =  write_answer_json(questions_xml_dir,answer_file_full_name, question_id, branch_question_id, answer, question_types)
              if info[:status] == true
                file_url = info[:url]
                answer_count = 0
                if question_types == Question::TYPES[:LISTENING]
                  answer_count = student_answer_record.listening_answer_count + 1
                  student_answer_record.update_attributes(:listening_answer_count => answer_count,
                                                          :answer_file_url => file_url)
                  status = "success"
                  notice = "记录完成！"
                elsif question_types == Question::TYPES[:READING]
                  answer_count = student_answer_record.reading_answer_count + 1
                  student_answer_record.update_attributes(:reading_answer_count => answer_count,
                                                          :answer_file_url => file_url)
                  status = "success"
                  notice = "记录完成！"
                end
              end
            else
              status = "error"
              notice = "题包不存在！"
            end
          end
        else
          notice = "该班级不存在!"
        end
      else
        notice = "该用户不存在!"
      end
    else
      notice = "该任务包不存在!"
    end
    render :json => {"status" => status, "notice" => notice}
  end

  #获取历史答题记录
  def get_answer_history
    student_id = params[:student_id]
    school_class_id = params[:school_class_id]
    question_package_id = params[:question_package_id]
    student = Student.find_by_id student_id
    school_class = SchoolClass.find_by_id school_class_id
    question_package = QuestionPackage.find_by_id question_package_id

    status = "error"
    #读xml存入字符串变量
    question_packages_xml = ""
    questions_xml_dir = "#{Rails.root}/public/homework_system/question_packages
              /question_package_#{question_package.id}/answers/"
    file_url = "#{questions_xml_dir}student_#{student.id}.xml"
    File.open(file_url,"r") do |file|
      file.each do |line|
        question_packages_xml += line
      end
    end
    #转换成hash
    questions_collections = restruct_xml question_packages_xml

    render :json =>  {"status" => status, "questions" => questions_collections}
  end

  #完成某个题包
  def finish_question_packge
    student_id = params[:student_id]
    school_class_id = params[:school_class_id]
    publish_question_package_id = params[:publish_question_package_id]
    student_answer_record = StudentAnswerRecord.find_by_student_id_and_school_class_id_and_publish_question_package_id student_id,school_class_id,publish_question_package_id
    if !student_answer_record.nil?
      if student_answer_record.status == StudentAnswerRecord::STATUS[:DEALING]
        if student_answer_record.update_attributes(:status => StudentAnswerRecord::STATUS[:FINISH])
          notice = "作业状态更新完成!"
          status = "success"
        else
          notice = "作业状态更新失败,请重新操作!"
          status = "error"
        end
      else
        notice = "该作业已完成!"
        status = "error"
      end
    else
      notice = "参数错误!"
      status = "error"
    end
    render :json => {:status => status, :notice => notice}
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
          school_class_student_relations = SchoolClassStudentRalastion.
              find_by_school_class_id_and_student_id school_class.id, student.id
          if school_class_student_relations.nil?
            school_class_student_relations = student.school_class_student_ralastions.
                create(:school_class_id => school_class.id)
          end
          class_id = school_class.id
          class_name = school_class.name
          tearcher_id = school_class.teacher.id
          tearcher_name = school_class.teacher.user.name
          classmates = SchoolClass.get_classmates school_class
          task_messages = TaskMessage.get_task_messages school_class.id
          page = 1
          microposts = Micropost.get_microposts school_class,page
          follow_microposts_id = Micropost.get_follows_id microposts, student.user.id
          daily_tasks = StudentAnswerRecord.get_daily_tasks school_class.id, student.id
          messages = Message.get_my_messages school_class, student.user.id
          render :json => {:status => "success", :notice => "验证成功！",
                           :student => {:id => student.id, :name => student.user.name, :user_id => student.user.id,
                                        :nickname => student.nickname, :avatar_url => student.user.avatar_url},
                           :class => {:id => class_id, :name => class_name, :tearcher_name => tearcher_name,
                                      :tearcher_id => tearcher_id },
                           :classmates => classmates,
                           :task_messages => task_messages,
                           :microposts => microposts,
                           :daily_tasks => daily_tasks,
                           :follow_microposts_id => follow_microposts_id,
                           :messages => messages
          }
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

  #获取我的提示消息
  def get_messages
    user_id = params[:user_id]
    school_class_id = params[:school_class_id]
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
          messages = Message.get_my_messages school_class, user_id
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
              sql_str = "select m.content, m.created_at, m.id micropost_id, m.reply_microposts_count,
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
    user = User.find_by_id user_id
    school_class = SchoolClass.find_by_id school_class_id
    student = user.student
    message = Message.find_by_id message_id
    if user.nil? || school_class.nil?
      status = "error"
      notice = "用户或班级信息错误,请重新登陆!"
    else
      if student.nil?
        status = "error"
        notice = "用户信息错误,请重新登陆!"
      else
        school_class_student_relations = SchoolClassStudentRalastion.
            find_by_student_id_and_school_class_id student.id, school_class.id
        if school_class_student_relations.nil?
          status = "error"
          notice = "用户与班级的关系不正确,请重新登陆!"
        else
          if message.nil?
            status = "error"
            notice = "消息不存在!"
          else
            if message.destroy
              status = "success"
              notice = "删除成功!"
            else
              status = "error"
              status = "删除失败!"
            end
          end
        end
      end
    end
    render :json => {:status => status, :notice => notice}
  end
end
