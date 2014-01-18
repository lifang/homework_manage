#encoding: utf-8
class ResultsController < ApplicationController
  
  def index
    school_class = SchoolClass.find_by_id params[:school_class_id].to_i
    if school_class
      @publish_packages = 
          PublishQuestionPackage.where(:school_class_id => school_class.id).order("created_at desc")
      @current_package = @publish_packages[0]    
      if @publish_packages.any?
        records = StudentAnswerRecord.ret_stuent_record(school_class.id, @current_package.id)       
         @answerd_users = records[0]
         @unanswerd_users = records[1]
      end      
    end  
  end
  
  def show
    school_class = SchoolClass.find_by_id params[:school_class_id].to_i
    if school_class
      @publish_packages = 
          PublishQuestionPackage.where(:school_class_id => school_class.id).order("created_at desc")
      @current_package = PublishQuestionPackage.find_by_id params[:id]
      if @publish_packages.any? and @current_package
        records = StudentAnswerRecord.ret_stuent_record(school_class.id, @current_package.id)       
         @answerd_users = records[0]
         @unanswerd_users = records[1]
      end      
    end
    render :index
  end
  
end
