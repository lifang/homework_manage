#encoding: utf-8
require 'rexml/document'
require 'rexml/element'
require 'rexml/parent'
require 'will_paginate'
require 'will_paginate/array'
include REXML
include MethodLibsHelper
class HomeworksController < ApplicationController
  before_filter :sign?
  #作业主页
  def index
    teacher = Teacher.find_by_id cookies[:teacher_id]
    @school_class = SchoolClass.find_by_id params[:school_class_id].to_i
    @publish_question_packages = Teacher.get_publish_question_packages @school_class.id
    page = params[:page]
    @publish_question_packages = @publish_question_packages.paginate(:page => page, :per_page => PublishQuestionPackage::PER_PAGE)
  end

  #删除题包
  def delete_question_package
    publish_question_package_id = params[:publish_question_package_id]
    school_class_id = params[:school_class_id]
    page = params[:page]
    page = 1  if !page
    @school_class = SchoolClass.find_by_id school_class_id
    publish_question_package = PublishQuestionPackage.find_by_id publish_question_package_id
    if !publish_question_package.nil?
      if publish_question_package.task_message.destroy && publish_question_package.destroy
        status = true
        notice = "任务删除成功！"
        @publish_question_packages = Teacher.get_publish_question_packages @school_class.id
        @publish_question_packages = @publish_question_packages.paginate(:page => page, :per_page => PublishQuestionPackage::PER_PAGE)
      else
        status = false
        notice = "任务删除失败！"
      end
    end
    @info = {:status => status, :notice => notice}
  end

  #发布（题包）任务
  def publish_question_package
    question_package_id = params[:question_package_id]
    school_class_id = params[:school_class_id]
    end_time = params[:end_time]
    teacher = Teacher.find_by_id cookies[:teacher_id]
    question_package = QuestionPackage.find_by_id question_package_id
    @school_class = SchoolClass.find_by_id school_class_id
    status = false
    notice = ""
    question_packages_url = nil
    if teacher && question_package && @school_class
      Teacher.transaction do
        all_questions = Question.get_all_questions question_package
        file_dirs_url = "#{Rails.root}/public/homework_system/question_packages/question_packages_#{question_package.id}"
        file_full_url = "#{file_dirs_url}/questions.js"
        if all_questions.length == 0
          p question_package
          status = false
          notice = "该题包下的题目或小题为空！"
        else
          #p all_questions
          write_file =  write_question_xml all_questions,file_dirs_url, file_full_url
          if write_file[:status] == true
            base_url = "#{Rails.root}/public"
            question_packages_url = "#{file_full_url.to_s[base_url.size,file_dirs_url.size]}"
          else
            question_packages_url = nil
          end

          publish_question_package = PublishQuestionPackage.create(:school_class_id => @school_class.id,
                                        :question_package_id => question_package.id,
                                        :start_time => Time.now, :end_time => end_time,
                                        :status => PublishQuestionPackage::STATUS[:NEW],
                                        :question_packages_url => question_packages_url )
          if publish_question_package
            status = true
            notice = "发布成功！"
            @publish_question_packages = Teacher.get_publish_question_packages @school_class.id
            page = params[:page]
            @publish_question_packages = @publish_question_packages.paginate(:page => page, :per_page => PublishQuestionPackage::PER_PAGE)
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
      end
    else
      status = false
      notice = "发布失败！"
    end
    @info = {:status => status, :notice => notice}
  end
end
