#encoding: utf-8
class HomeworksController < ApplicationController
  #作业主页
  def index
    teacher = Teacher.find_by_id session[:teacher_id]
    @school_class = SchoolClass.find_by_id session[:class_id]
    @publish_question_packages = Teacher.get_publish_question_packages @school_class.id
  end

  #删除题包
  def delete_question_package
    question_package_id = params[:question_package_id]
    school_class_id = params[:school_class_id]
    @school_class = SchoolClass.find_by_id school_class_id
    question_package = QuestionPackage.find_by_id question_package_id
    if !question_package.nil?
      if question_package.destroy
        status = true
        notice = "题包删除成功！"
        @publish_question_packages = Teacher.get_publish_question_packages @school_class.id
      else
        status = false
        notice = "题包删除失败！"
      end
    end
    @info = {:status => status, :notice => notice}
  end

  #发布（题包）任务
  def publish_question_package
    question_package_id = params[:question_package_id]
    school_class_id = params[:school_class_id]
    end_time = params[:end_time].to_s + " 23:59:59"
    teacher = Teacher.find_by_id session[:teacher_id]
    question_package = QuestionPackage.find_by_id question_package_id
    @school_class = SchoolClass.find_by_id school_class_id
    if teacher && question_package && @school_class
      Teacher.transaction do
        publish_question_package = PublishQuestionPackage.create(:school_class_id => @school_class.id,
                                      :question_package_id => question_package.id,
                                      :start_time => Time.now, :end_time => end_time,
                                      :status => PublishQuestionPackage::STATUS[:NEW])
        if publish_question_package
          status = true
          notice = "发布成功！"
          #@publish_question_packages = Teacher.get_publish_question_packages @school_class.id
          content = "教师：#{teacher.user.name}于#{publish_question_package.created_at}发布了一个任务
                  '#{publish_question_package.question_package.name}',
                  任务截止时间：#{publish_question_package.end_time}"
          @school_class.task_messages.create(:content => content,
                    :period_of_validity => publish_question_package.end_time,
                    :status => TaskMessage::STATUS[:YES],
                    :publish_question_package_id => publish_question_package.id)

        else
          status = false
          notice = "发布失败！"
        end
      end
    else
      status = false
      notice = "发布失败！"
    end
    @info = {:status => status, :notice => "发布成功！"}
  end
end
