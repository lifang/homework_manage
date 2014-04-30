#encoding: utf-8
require 'archive/zip'
require 'rexml/document'
require 'rexml/element'
require 'rexml/parent'
require 'time'
include REXML
include MethodLibsHelper
include MicropostsHelper
class HomeworksController < ApplicationController
  #作业主页
  def index
    @school_class = SchoolClass.find_by_id params[:school_class_id].to_i
    page = params[:page]
    tasks = Teacher.get_publish_question_packages @school_class.id, page
    @publish_question_packages = tasks[:publish_question_packages]
    @un_delete_task = tasks[:un_delete]
    @all_pack_types_name = tasks[:all_pack_types_name]
    @school_tags = @school_class.tags  #班级分组， 用于发布作业的时候选择分组
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
        questions_file_dir = "#{base_url}/#{publish_ques_path(school_class_id, publish_question_package.question_package_id)}"
        FileUtils.remove_dir questions_file_dir if File.exist? questions_file_dir
        if publish_question_package.task_message && publish_question_package.task_message.destroy
          student_answer_record_dir = "#{base_url}/pub_que_ps/#{@school_class.id}/pub_#{publish_question_package.id}"
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
    page = params[:page].present? ? params[:page].to_i : 1
    @page = page
    question_package_id = params[:question_package_id]
    school_class_id = params[:school_class_id]
    end_time = params[:end_time]
    time_now = Time.now.strftime("%F %T")
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
          file_dirs_url = publish_ques_path(school_class_id, question_package.id)
          file_full_name = "questions.json"
          if all_questions.length == 0
            notice = "该题包下的题目或小题为空！"
          else
            tmp_q_length = all_questions.map(&:questions_time).compact.length
            if tmp_q_length != all_questions.length
              notice = "该题包下有题目未设置时间,请设置完成再发布！"
            else

              write_file =  write_question_xml all_questions,file_dirs_url, file_full_name
              if write_file[:status] == true
                question_packages_url = "/#{file_dirs_url}/#{file_full_name}"
              else
                question_packages_url = nil
              end
              #            group_questions = all_questions.group_by {|e| e.types}
              #            listening_count = group_questions[0].nil? ? 0 : group_questions[0].length
              #            reading_count = group_questions[1].nil? ? 0 : group_questions[1].length
              publish_question_package = PublishQuestionPackage.create(:school_class_id => @school_class.id,
                :question_package_id => question_package.id,
                :start_time => time_now, :end_time => end_time,
                :status => PublishQuestionPackage::STATUS[:NEW],
                :question_packages_url => question_packages_url,
                :tag_id => params[:tag_id])
              question = question_package.questions[0]
              question_package.update_attribute(:name, question.question_package_name) if question
              if publish_question_package
                wanxin_ids = Question.where("question_package_id = ? and types = ?",question_package_id,Question::TYPES[:CLOZE])
                wanxin_ids = wanxin_ids.map(&:id) unless wanxin_ids.blank?
#                deal_wanxin wanxin_ids
                status = true
                notice = "发布成功！"
                @publish_question_packages = Teacher.get_publish_question_packages @school_class.id, page
                content = "教师：#{teacher.user.name}发布了一个任务,任务截止时间：#{publish_question_package.end_time.strftime("%F %T")}"
                @school_class.task_messages.create(:content => content,
                  :period_of_validity => publish_question_package.end_time,
                  :status => TaskMessage::STATUS[:YES],
                  :publish_question_package_id => publish_question_package.id)
                 compress_and_push file_dirs_url,question_package_id,@school_class,content,publish_question_package
              end
            end

          end
        end
      end
    else
      notice = "结束时间不能小于当前时间！"
    end
    @info = {:status => status, :notice => notice}
    respond_to do |f|
      f.json{ render :json => @info}
      f.js{}
    end
  end
private
  def deal_wanxin wanxin_ids
    b_qs = BranchQuestion.where("question_id in (?)",wanxin_ids);
    unless b_qs.blank?
      branch_questions_by_questions =b_qs.group_by{|b| b.question_id}
      branch_questions_by_questions.each do |question_id,branch_questions|
        branch_questions.each_with_index do |branch_question,index|
          branch_question.update_attribute(:content,index+1)
        end
      end
    end
    
  end

end
