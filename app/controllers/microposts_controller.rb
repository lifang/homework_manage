#encoding:utf-8
class MicropostsController < ApplicationController
  before_filter :get_school_class
  def index
   
  end
  
  def create
    content = params[:microposts][:content]
    micropost = Micropost.new
    micropost.content = content
    micropost.user_id = current_teacher.user_id
    micropost.user_types = 0
    micropost.school_class_id = current_teacher.last_visit_class_id
    micropost.reply_microposts_count = 0
    if micropost.save
      flash[:success]='发表成功！' 
      redirect_to school_class_main_pages_path(@school_class)
    else
      flash[:success]='发表失败！'
      render 'main_pages/index'
    end
  end
  
  def create_reply
    get_microposts
    reply = ReplyMicropost.new
    reply.content = params[:textarea]
    reply.micropost_id = params[:micropost_id]
    reply.sender_id = params[:teacher_id]
    reply.sender_types = 0
    reply.reciver_id = params[:micropost_user_id]
    reply.reciver_types = params[:micropost_user_type]
    if reply.save
      Message.add_messages(reply.micropost_id, reply.reciver_id, reply.reciver_types,
        reply.sender_id, reply.sender_types,reply.content, current_teacher.last_visit_class_id)
      flash[:success]='chenggong'
    else
      flash[:error]='shibai'
    end
  end
  def delete_micropost
    
    reply = Micropost.find_by_id(params[:id])
    if reply&&reply.destroy
      get_microposts
      flash[:success]='删除成功'
    else
      flash[:success]='删除失败'
    end
  end
  def delete_micropost_reply
    reply = ReplyMicropost.find_by_id(params[:id])
    if reply&&reply.destroy
      get_microposts 
      flash[:success]='删除成功'
    else
      flash[:success]='删除失败'
    end
  end
  
  def get_microposts 
    @condition = params[:condtions]
    @condition = nil if params[:condtions]==""
    @scclass = SchoolClass.find(current_teacher.last_visit_class_id)
    @classmates = SchoolClass::get_classmates(@scclass)
    array = Micropost::get_microposts @scclass,params[:page],@condition
    @microposts =array[:details_microposts]
  end

  def add_reply_page
    @index = params[:index].to_i
    @current_page = params[:current_page].to_i+1
    micropost_id = params[:micropost_id]
    micropost = Micropost.find_by_id(micropost_id)
    @scclass = SchoolClass.find(current_teacher.last_visit_class_id)
    array = ReplyMicropost::get_microposts micropost.id,@current_page
    @reply = array[:reply_microposts]
  end
  
end
