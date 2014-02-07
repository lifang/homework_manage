#encoding: utf-8
class ResultsController < ApplicationController
  before_filter :sign?
  
  def index
    @school_class = SchoolClass.find_by_id params[:school_class_id].to_i
    if @school_class
      @publish_packages = 
          PublishQuestionPackage.where(:school_class_id => @school_class.id).order("created_at desc")
      @current_package = @publish_packages[0]    
      if @publish_packages.any?
        records = StudentAnswerRecord.ret_stuent_record(@school_class.id, @current_package.id)       
         @answerd_users = records[0]
         @unanswerd_users = records[1]
         @question_package = @current_package.question_package
      end      
    end  
  end
  
  def show
    @school_class = SchoolClass.find_by_id params[:school_class_id].to_i
    if @school_class
      @publish_packages = 
          PublishQuestionPackage.where(:school_class_id => @school_class.id).order("created_at desc")
      @current_package = PublishQuestionPackage.find_by_id params[:id]
      if @publish_packages.any? and @current_package
        records = StudentAnswerRecord.ret_stuent_record(@school_class.id, @current_package.id)       
         @answerd_users = records[0]
         @unanswerd_users = records[1]
         @question_package = @current_package.question_package
      end      
    end
    render :index
  end
  
  def show_single_record
    s_record = StudentAnswerRecord.find_by_id params[:record_id] if params[:record_id]
    @user = User.find_by_id params[:user_id]
    answer_json = File.open("#{Rails.root}/public#{s_record.answer_file_url}").read if s_record and s_record.answer_file_url
    @package_json = ActiveSupport::JSON.decode(answer_json) if answer_json
    respond_to do |format|
      format.js
    end
  end
  
end
