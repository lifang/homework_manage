#encoding: utf-8
require 'rexml/document'
require 'rexml/element'
require 'rexml/parent'
require 'time'
include REXML
include MethodLibsHelper
class HomeworksController < ApplicationController
  before_filter :sign?
  #作业主页
  def index
    teacher = Teacher.find_by_id cookies[:teacher_id]
    @school_class = SchoolClass.find_by_id params[:school_class_id].to_i
    page = params[:page]
    @publish_question_packages = Teacher.get_publish_question_packages @school_class.id, page
  end

  #删除题包
  def delete_question_package
    base_url = "#{Rails.root}/public"
    publish_question_package_id = params[:publish_question_package_id]
    school_class_id = params[:school_class_id]
    page = params[:page]
    status = false
    notice = "任务删除失败！"
    page = 1  if !page
    @school_class = SchoolClass.find_by_id school_class_id
    publish_question_package = PublishQuestionPackage.find_by_id publish_question_package_id
    if !publish_question_package.nil?
      student_answer_records = StudentAnswerRecord.
          where("publish_question_package_id = ? and school_class_id = ?",
                publish_question_package.id,@school_class.id)
      if student_answer_records.length == 0
        questions_file_dir = "#{base_url}/que_ps/question_p_#{publish_question_package.question_package_id}"
        FileUtils.remove_dir questions_file_dir if File.exist? questions_file_dir
        if publish_question_package.task_message && publish_question_package.task_message.destroy
          student_answer_record_dir = "#{base_url}/pub_que_ps/pub_#{publish_question_package.id}"
          #删除答题文件
          FileUtils.remove_dir student_answer_record_dir if Dir.exist? student_answer_record_dir
          #删除答题记录
          StudentAnswerRecord.delete_all("question_package_id = #{publish_question_package.question_package.id}")
          #作业删除文件夹开始
          delete_question_package_folder(publish_question_package.question_package)
          #作业删除文件夹结束
          publish_question_package.question_package.destroy
          publish_question_package.destroy
          status = true
          notice = "任务删除成功！"
        end
      else
        notice = "已有学生答题，不能删除任务！"
      end
    else
      notice = "任务删除失败！"
    end
    @info = {:status => status, :notice => notice}
  end

  #发布（题包）任务
  def publish_question_package
    page = params[:page]
    page = 1  if !page
    question_package_id = params[:question_package_id]
    school_class_id = params[:school_class_id]
    end_time = params[:end_time]
    time_now = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    status = false
    notice = "发布失败！"
    if (end_time <=> time_now) > 0
      teacher = Teacher.find_by_id cookies[:teacher_id]
      question_package = QuestionPackage.find_by_id question_package_id
      @school_class = SchoolClass.find_by_id school_class_id
      question_packages_url = nil
      if teacher && question_package && @school_class
        Teacher.transaction do
          all_questions = Question.get_all_questions question_package
          file_dirs_url = "que_ps/question_p_#{question_package.id}"
          file_full_name = "questions.js"
          if all_questions.length == 0
            notice = "该题包下的题目或小题为空！"
          else
            write_file =  write_question_xml all_questions,file_dirs_url, file_full_name
            if write_file[:status] == true
              question_packages_url = "/#{file_dirs_url}/#{file_full_name}"
            else
              question_packages_url = nil
            end
            group_questions = all_questions.group_by {|e| e.types}
            listening_count = group_questions[0].nil? ? 0 : group_questions[0].length
            reading_count = group_questions[1].nil? ? 0 : group_questions[1].length
            publish_question_package = PublishQuestionPackage.create(:school_class_id => @school_class.id,
              :question_package_id => question_package.id,
              :start_time => time_now, :end_time => end_time,
              :status => PublishQuestionPackage::STATUS[:NEW],
              :listening_count => listening_count,
              :reading_count => reading_count,
              :question_packages_url => question_packages_url )
            if publish_question_package
              status = true
              notice = "发布成功！"
              @publish_question_packages = Teacher.get_publish_question_packages @school_class.id, page
              page = params[:page]
              @publish_question_packages = @publish_question_packages.paginate(:page => page, :per_page => PublishQuestionPackage::PER_PAGE)
              content = "教师：#{teacher.user.name}于#{publish_question_package.created_at}发布了一个任务
                      '#{publish_question_package.question_package.name}',
                      任务截止时间：#{publish_question_package.end_time}"
              @school_class.task_messages.create(:content => content,
                :period_of_validity => publish_question_package.end_time,
                :status => TaskMessage::STATUS[:YES],
                :publish_question_package_id => publish_question_package.id)
            end
          end
        end
      end
    else
      notice = "结束时间不能小于当前时间！"
    end
    @info = {:status => status, :notice => notice}
  end
end
