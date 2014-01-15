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
      :content => content, :school_class_id => school_class_id)
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
    replymicropost = ReplyMicropost.new(:sender_id => sender_id, 
      :sender_types => sender_types, :content => content,
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
    classes = SchoolClass.find_by_sql(["SELECT school_classes.id class_id,school_classes.name class_name
            from school_classes INNER JOIN school_class_student_ralastions 
            on school_classes.id = school_class_student_ralastions.school_class_id
            where school_classes.status = ? and school_classes.period_of_validity >= ?
            and school_class_student_ralastions.student_id = ?", 
            student_id, Time.now(), SchoolClass::STATUS[:NORMAL]])
    render :json => {:classes => classes}
  end
  
  #我的消息
  def my_microposts    
    school_class = SchoolClass.find_by_id params[:school_class_id].to_i
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
    p_q_package_id = params[:publish_question_package_id]
    p_q_package = PublishQuestionPackage.find_by_id p_q_package_id.to_i
    package_json = ""
    answer_json = ""
    status = false
    #if p_q_package
      #package_json = File.open("#{Rails.root}/public/#{p_q_package.question_package_url}").read if p_q_package and p_q_package.question_package_url
      package_json = File.open("#{Rails.root}/public/question_package_1.js").read
      s_a_record = StudentAnswerRecord.find_by_student_id_and_publish_question_package_id(student_id, p_q_package_id)
      #if s_a_record
        #answer_json = File.open("#{Rails.root}/public/#{s_a_record.answer_file_url}").read if s_a_record and s_a_record.answer_file_url
        answer_json = File.open("#{Rails.root}/public/answer_file_1.js").read
      #end
      status = true
    #end
    notice = status == false ? "没有作业内容" : ""
    render :json => {:status => status, :notice => notice, :package => ActiveSupport::JSON.decode(package_json), 
      :user_answers => ActiveSupport::JSON.decode(answer_json)}
  end

  #获取消息microposts(分页)
  def get_microposts
    school_class_id = params[:school_class_id]
    student_id = params[:student_id]
    page = params[:page].to_i
    school_class = SchoolClass.find_by_id school_class_id
    student = Student.find_by_id student_id
    microposts = nil
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
              microposts = nil
            else
              status = "success"
              notice = "加载完成"
              microposts = Micropost.get_microposts school_class,page
            end
          else
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
    file = params[:avatar] #上传头像
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
      Student.transaction do
        time_to_month = Time.now.to_s[0,8]
          student = Student.create(:nickname => nickname, :qq_uid => qq_uid,
              :last_visit_class_id => school_class.id)
          destination_dir = "#{Rails.root}/public/homework_system/avatars/students/#{time_to_month}"
          rename_file_name = "student_#{student.id}"
          upload = upload_file destination_dir, rename_file_name, file
          url = upload[:url]
          unuse_url = "#{Rails.root}/public"
          avatar_url = url.to_s[unuse_url.size,url.size]
          if upload[:status] == 0  #上传文件
            user = User.create(:name => name, :avatar_url => avatar_url)
            student.update_attributes(:user_id => user.id)
            student.school_class_student_ralastions.create(:school_class_id => school_class.id)
            class_id = school_class.id
            class_name = school_class.name
            tearcher_id = school_class.teacher.id
            tearcher_name = school_class.teacher.user.name
            classmates = SchoolClass.get_classmates school_class
            task_messages = TaskMessage.get_task_messages school_class.id
            page = 1
            microposts = Micropost.get_microposts school_class,page
            p student
            daily_tasks = StudentAnswerRecord.get_daily_tasks school_class.id, student.id

            url = upload[:url]

            unuse_url = "#{Rails.root}/public"
            render :json => {:status => "success", :notice => "登记成功！",
                             :student => {:id => student.id, :name => student.user.name,
                                          :nickname => student.nickname, :avatar_url => student.user.avatar_url},
                             :class => {:id => class_id, :name => class_name, :tearcher_name => tearcher_name,
                                        :tearcher_id => tearcher_id },
                             :classmates => classmates,
                             :task_messages => task_messages,
                             :microposts => microposts,
                             :daily_tasks => daily_tasks
            }
          else
            status = "error"
            notice = "上传失败"
            render :json => {:status => status, :notice => notice}
          end
          #notice = "qq账号已经注册,请直接登陆"
          #status = "error"
          #render :json => {:status => status, :notice => notice}
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
        tearcher_name = school_class.teacher.user.name
        classmates = SchoolClass.get_classmates school_class
        task_messages = TaskMessage.get_task_messages school_class.id
        page = 1
        microposts = Micropost.get_microposts school_class,page
        daily_tasks = StudentAnswerRecord.get_daily_tasks school_class.id, student.id
        render :json => {:status => "success", :notice => "登陆成功！",
                         :student => {:id => student.id, :name => student.user.name,
                                      :nickname => student.nickname, :avatar_url => student.user.avatar_url},
                         :class => {:id => class_id, :name => class_name, :tearcher_name => tearcher_name,
                                    :tearcher_id => tearcher_id },
                         :classmates => classmates,
                         :task_messages => task_messages,
                         :microposts => microposts,
                         :daily_tasks => daily_tasks
        }
      else
        render :json => {:status => "error", :notice => "班级信息错误！"}
      end
    end
  end

  #记录答题信息
  def record_answer_info
    student_id = params[:student_id]
    school_class_id = params[:school_class_id]
    question_package_id = params[:question_package_id]
    question_id = params[:question_id]
    branch_question_id = params[:branch_question_id]
    answer = params[:answer]
    question_types = params[:question_types]  #题型:听力或朗读
    student = Student.find_by_id student_id
    school_class = SchoolClass.find_by_id school_class_id
    question_package = QuestionPackage.find_by_id question_package_id
    status = "error"
    notice = "参数错误!"

    url = "/"
    count = 0
    questions_xml_dir = "#{Rails.root}/public/homework_system/question_packages/
      question_package_#{question_package.id}/answers"
    questions_xml_dir.split("/").each_with_index  do |e,i|
      if i > 0 && e.size > 0
        url = url + "/" if count > 0
        url = url + "#{e}"
        if !Dir.exist? url
          Dir.mkdir url
        end
        count = count +1
      end
    end

    if !student.nil?
      if !school_class.nil? && !question_package.nil?
        school_class_student_relation = SchoolClassStudentRalastion.
            find_all_by_school_class_id_and_student_id school_class.id, student.id
        if school_class_student_relation.nil?
          notice = "该学生不属于当前班级,操作失败!"
        else
          student_answer_record = StudentAnswerRecord.
              find_by_student_id_and_question_package_id student.id, question_package.id
          if !student_answer_record.nil?
            student_answer_record = student.student_answer_records.
                create(:question_package_id => question_package.id)
          end
        end
      end
    end

    file_url = "#{questions_xml_dir}/student_#{student.id}.xml"
    p file_url
    if write_xml(file_url, question_id, branch_question_id, answer, question_types) == true
      status = "success"
      notice = "记录完成"
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
    question_package_id = params[:question_package_id]
    publish_question_package_id = params[:publish_question_package_id]
    student_answer_record = StudentAnswerRecord.find_by_student_id_and_school_class_id_and_publish_question_package_id_and_question_package_id student_id,school_class_id,publish_question_package_id,question_package_id
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
    sender_id = params[:sender_id]
    sender_types = params[:sender_id]
    status = "error"
    notice = "删除失败!"
    reply_micropost =  ReplyMicropost.find_by_id_and_sender_id_and_sender_types reply_micropost_id, sender_id, sender_types
    if reply_micropost.nil?
    else
      if reply_micropost.destroy
        status = "success"
        notice = "删除成功!"
      end
    end
    render :json => {:status => status, :notice => notice}
  end

  #加入新班级
  def validate_verification_code
    verification_code = params[:verification_code]
    student_id = params[:student_id]
    student = Student.find_by_id student_id
    if student.nil?
      status = "error"
      notice = "学生信息错误，请重新登陆！"
    else
      school_class = SchoolClass.find_by_verification_code verification_code
      if !school_class.nil?
        #if school_class.period_of_validity #失去有限期
        #else
        #end
        school_class_student_relations = SchoolClassStudentRalastion.
            find_by_school_class_id_and_student_id school_class.id, student.id
        if school_class_student_relations.nil?
          school_class_student_relations = student.school_class_student_ralastions.
              create(:school_class_id => school_class.id)
        end
      else
        status = "error"
        notice = "班级信息错误！"
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
end
