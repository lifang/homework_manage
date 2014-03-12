#encoding: utf-8
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
  end

  #根据标签显示完成情况
  def show_tag_task
    date = params[:date]
    pub_id = params[:pub_id].to_i
    tag_id = params[:tag_id]
    @current_task = PublishQuestionPackage.find_by_id pub_id
    info = PublishQuestionPackage.get_record_details(@current_task,
                    tag_id,@current_task.school_class_id)
    @question_types = info[:question_types]
    @details = info[:details]
    @average_complete_rate = info[:average_complete_rate]
    @average_correct_rate = info[:average_correct_rate]
    p @question_types
    p @details
    p @average_complete_rate
    p @average_correct_rate
  end
end
