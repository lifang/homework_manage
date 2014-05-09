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
    if_from_shared = params[:if_from_shared].to_i
    status = false
    notice = "发布失败！"
    if (end_time <=> time_now) > 0
      teacher = Teacher.find_by_id cookies[:teacher_id]

      question_package = (if_from_shared == 1 ? ShareQuestionPackage : QuestionPackage).find_by_id question_package_id
      @school_class = SchoolClass.find_by_id school_class_id
      question_packages_url = nil
      if teacher && question_package && @school_class
        Teacher.transaction do
          if if_from_shared == 1
            all_questions = ShareQuestion.get_all_share_questions question_package
          else
            all_questions = Question.get_all_questions question_package
          end
          if all_questions.length == 0
            notice = "该题包下的题目或小题为空！"
          else
            tmp_q_length = all_questions.map(&:questions_time).compact.length
            if tmp_q_length != all_questions.length
              notice = "该题包下有题目未设置时间,请设置完成再发布！"
            else
              if if_from_shared == 1
                new_question_package = clone_share_question_package_to_question_package(question_package, school_class_id)
                new_all_questions = Question.get_all_questions new_question_package
                common_publish_question_package(school_class_id, new_question_package, time_now, end_time, page, new_all_questions, teacher)
              else
                common_publish_question_package(school_class_id, question_package, time_now, end_time, page, all_questions, teacher)
              end
              flash[:notice] = @notice
              status, notice = @status, @notice
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

  #新建快捷题包
  def new_publish
    @school_class = SchoolClass.find_by_id params[:school_class_id].to_i
    @cells = Cell.where("teaching_material_id = ?",@school_class.teaching_material_id )
    @school_tags = @school_class.tags  #班级分组， 用于发布作业的时候选择分组
  end
  
  #新建快捷题包，根据cell_id and episode_id获取快捷题包
  def get_share_question_package_id
    cell_id, episode_id = params[:cell_id], params[:episode_id]
    share_question_package = ShareQuestionPackage.find_by_cell_id_and_episode_id(cell_id, episode_id)
    if share_question_package
      status = 0
      share_question_package_id = share_question_package.id
      show_href = "/question_admin/share_question_packages/#{share_question_package.id}?school_class_id=#{school_class_id}"
    else
      status = -1
      share_question_package_id = ""
      show_href = ""
    end
    render :json => {:status => status, :pre_href => show_href, :ques_pack_id => share_question_package_id}
  end


  #发布快捷题包之前克隆一份
  def clone_share_question_package_to_question_package(share_question_package, school_class_id)
    if share_question_package
      new_question_pack = QuestionPackage.create(:name => share_question_package.name, :school_class_id => school_class_id)
      share_question_package.share_questions.each do |share_question|
        question_attributes = share_question.attributes.extract!("name","types", "cell_id", "episode_id", "questions_time", "full_text")
        new_question = new_question_pack.questions.create(question_attributes)
        new_question.if_shared = Question::IF_SHARED[:NO]
        new_question.if_from_reference = Question::IF_FROM_REFER[:NO]
        new_question.save
        share_question.share_branch_questions.each do |bq|  #bq = share_branch_question
          branch_question = new_question.branch_questions.create({:content => bq.content, :options => bq.options, :answer => bq.answer, :types => bq.types})
          new_content =  bq.content
          #选择题的话，内容里面有资源，复制资源
          if bq.types == Question::TYPES[:SELECTING] && bq.content.present? && bq.content.include?("<file>")
            content = bq.content.split("</file>")[1]
            content_file = bq.content.split("</file>")[0].split("<file>")[1]
            new_content_file = copy_file(media_path, new_question_pack, branch_question, content_file) if content_file.present?
            new_content = "<file>#{new_content_file}</file>#{content}"
          end

          new_resource_url = copy_file(media_path, new_question_pack, branch_question, bq.resource_url) if bq.resource_url.present? #引用的时候，拷贝音频
          branch_question.update_attributes(:resource_url => new_resource_url, :content => new_content)
          bq.branch_tags.each do |bt|
            branch_question.branch_tags << bt
          end
        end if share_question && share_question.share_branch_questions
      end if share_question_package.share_questions
    end
    return new_question_pack
  end

  
  def common_publish_question_package(school_class_id, question_package, time_now, end_time, page, all_questions, teacher)
    file_dirs_url = publish_ques_path(school_class_id, question_package.id)
    file_full_name = "questions.json"
    write_file =  write_question_xml all_questions,file_dirs_url, file_full_name
    if write_file[:status] == true
      question_packages_url = "/#{file_dirs_url}/#{file_full_name}"
    else
      question_packages_url = nil
    end
    publish_question_package = PublishQuestionPackage.create(:school_class_id => school_class_id,
      :question_package_id => question_package.id,
      :start_time => time_now, :end_time => end_time,
      :status => PublishQuestionPackage::STATUS[:NEW],
      :question_packages_url => question_packages_url,
      :tag_id => params[:tag_id])
    question = question_package.questions[0]
    question_package.update_attribute(:name, question.question_package_name) if question
    if publish_question_package
      wanxin_ids = Question.where("question_package_id = ? and types = ?",question_package.id,Question::TYPES[:CLOZE])
      wanxin_ids = wanxin_ids.map(&:id) unless wanxin_ids.blank?
      @status = true
      @notice = "发布成功！"
      @publish_question_packages = Teacher.get_publish_question_packages school_class_id, page
      content = "教师：#{teacher.user.try(:name)}发布了一个任务,任务截止时间：#{publish_question_package.end_time.strftime("%F %T")}"
      @school_class.task_messages.create(:content => content,
        :period_of_validity => publish_question_package.end_time,
        :status => TaskMessage::STATUS[:YES],
        :publish_question_package_id => publish_question_package.id)
      compress_and_push file_dirs_url, question_package.id,@school_class,content,publish_question_package
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
