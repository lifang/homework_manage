class Api::StudentsController < ApplicationController
  #  发布消息
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
  #  回复消息
  def reply_message
    sender_id = params[:sender_id]
    sender_types = params[:sender_types]
    content = params[:content]
    micropost_id = params[:micropost_id]
    reciver_id = params[:reciver_id]
    reciver_types = params[:reciver_types]
    replymicropost = ReplyMicropost.new(:sender_id => sender_id, :sender_types => sender_types, :content => content,
      :micropost_id => micropost_id, :reciver_id => reciver_id,:reciver_types => reciver_types)
    if replymicropost.save
      render :json => "success"
    else
      render :json => "fails"
    end
  end
  #  关注消息api
  def add_concern
    student_id = params[:student_id]
    micropost_id = params[:micropost_id]
    followmicropost = FollowMicropost.new(:student_id => student_id, :micropost_id => micropost_id)
    if followmicropost.save
      render :json => "success"
    else
      render :json => "fails"
    end
  end
  #切换班级
  def switching_classes
    student_id = params[:student_id].to_i
    classes = SchoolClass.find_by_sql("SELECT school_classes.id class_id,school_classes.name class_name
from school_classes INNER JOIN school_class_student_ralastions on school_classes.id = school_class_student_ralastions.class_id
and school_class_student_ralastions.student_id =#{student_id}")
    render :json => {:classes => classes}
  end
end
