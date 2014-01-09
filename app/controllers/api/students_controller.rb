#encoding: utf-8
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
    student = Student.find_by_id(student_id)
    answer_file_url = student.answer_file_url
    
    school_class_id = params[:school_class_id].to_i
    types = params[:types].to_i
    questions = Question.find_by_sql("SELECT q.id id,q.name name FROM publish_question_packages  pqp INNER JOIN questions q
ON  pqp.question_package_id = q.question_package_id and pqp.status = #{PublishQuestionPackage::STATUS[:FINISH]}
and pqp.school_class_id = #{school_class_id} and q.types = #{types}")
    #    questions_hashs = Hash.new
    questions_arrs = Array.new
    questions.each do |question|
      questions_hash = Hash.new
      question_name = question.name
      question_id = question.id
      brahch_question = BranchQuestion.find_by_sql("SELECT id,content,types,resource_url FROM branch_questions WHERE question_id = #{question_id}")
      questions_hash["question_name"] = question_name
      questions_hash["question_id"] = question_id
      questions_hash["brahch_question"] = brahch_question
      questions_arrs << questions_hash
    end
    if types.eql?(Question::TYPES[:LISTENING])
      render :json => {:questions => {:listen => questions_arrs}, :finish_question => "1,2,3,4"}
    else
      render :json => {:questions => {:reading => questions_arrs}, :finish_question => "1,2,3,4"}
    end
  end

  #获取消息microposts(分页)
  def get_microposts
    school_class_id = params[:school_class_id]
    page = params[:page]
    school_class = SchoolClass.find_by_id school_class_id
    if school_class.nil?
      status = "error"
      notice = "班级不存在"
      microposts = nil
    else
      if school_class.status == SchoolClass::STATUS[:NORMAL]
        status = "success"
        notice = "加载完成"
        if page.nil?
          status = "error"
          notice = "页数为空"
          microposts = nil
        else
          microposts = Micropost.get_microposts school_class,page
        end
      else
        status = "error"
        notice = "班级已过期"
        microposts = nil
      end
    end
    render :json => {:status => status, :notice => notice,:microposts => microposts}
  end

  #学生登记个人信息，验证班级code，记录个人信息
  #问题: 1.qq_uid和必须唯一,昵称是否唯一,如果也唯一,那么无论由于昵称还是qq_uid的导致的添加失败,无法鉴别
  #     2.班级验证码是否唯一(个人觉得需要唯一,不然无法根据验证码查找班级,但是教师使用起来会有困惑)
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
          notice = "验证码错误!"
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
