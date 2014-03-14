#encoding: utf-8
include StatisticsHelper
class StatisticsController < ApplicationController
  layout "tapplication"
  #完成率及正确率统计
  def index
    school_class_id = params[:school_class_id]
    school_class = SchoolClass.find_by_id school_class_id
    @today_date = Time.now.strftime("%Y-%m-%d")
    info = PublishQuestionPackage.get_homework_statistics @today_date, school_class
    @all_tags = info[:all_tags]
    @current_task = info[:current_task]
    @current_date =  @current_task.nil? ? @today_date : @current_task.created_at.strftime("%Y-%m-%d")
    @question_types = info[:question_types]
    @details = info[:details]
    @average_correct_rate = info[:average_correct_rate]
    @average_complete_rate = info[:average_complete_rate]
  end

  #切换日期
  def checkout_by_date
    school_class_id = params[:school_class_id]
    date = params[:date]
    school_class = SchoolClass.find_by_id school_class_id
    @today_date = Time.now.strftime("%Y-%m-%d")
    info = PublishQuestionPackage.get_homework_statistics date, school_class
    @all_tags = info[:all_tags]
    @current_task = info[:current_task]
    @current_date = date
    @question_types = info[:question_types]
    @details = info[:details]
    @average_correct_rate = info[:average_correct_rate]
    @average_complete_rate = info[:average_complete_rate]
    p @details
    p @question_types
  end

  #根据标签显示完成率及正确率统计
  def show_tag_task
    date = params[:date]
    pub_id = params[:pub_id].to_i
    tag_id = params[:tag_id]
    @current_task = PublishQuestionPackage.find_by_id pub_id
    info = PublishQuestionPackage.get_record_details(@current_task,tag_id, @current_task.school_class_id)
    @question_types = info[:question_types]
    @details = info[:details]
    @average_complete_rate = info[:average_complete_rate]
    @average_correct_rate = info[:average_correct_rate]
  end

  #获取该任务下题型统计信息
  def show_question_statistics
    pub_id = params[:pub_id].to_i
    school_class_id = params[:school_class_id]
    publish_question_package = PublishQuestionPackage.find_by_id pub_id
    tag_id = publish_question_package.tag_id unless publish_question_package.nil?
    info = PublishQuestionPackage.get_quetion_types_statistics(publish_question_package,
          tag_id, school_class_id)
    @question_types = info[:question_types]
    p @question_types
  end

  #正确率列表——显示错题
  def show_incorrect_questions
    question_types = params[:question_types].to_i
    student_answer_record = params[:student_answer_record]
    student_answer_record = StudentAnswerRecord.find_by_id student_answer_record
    record_details = RecordDetail.find_by_student_answer_record_id student_answer_record.id unless student_answer_record.nil?
    @status = false
    @notice = "该学生的答题记录不存在！"
    if !student_answer_record.nil? && !student_answer_record.answer_file_url.nil?
      if record_details.nil?
        @notice = "该学生的#{Question::TYPES_NAME[:question_types]}答题记录为空！"
      end
    end
  end
end
