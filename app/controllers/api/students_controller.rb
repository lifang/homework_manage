class Api::StudentsController < ApplicationController
  def news_release
    content = params[:content]
    user_id = params[:user_id]
    user_types = params[:user_types]
    school_class_id = params[:school_class_id]
    micropost = Micropost.new(:user_id => user_id, :user_types => user_types, :content => content, :school_class_id => school_class_id)
    if micropost.save
      render :json => "success"
    else
      render :json => "fails"
    end
  end
end
