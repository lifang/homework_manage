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
    micropost.user_types = Micropost::USER_TYPES[:TEACHER]
    micropost.school_class_id = current_teacher.last_visit_class_id
    #    micropost.reply_microposts_count = 0
    if micropost.save
      flash[:success]='发表成功！'
      redirect_to school_class_main_pages_path(@school_class)
    else
      flash[:success]='发表失败！'
      render 'main_pages/index'
    end
  end

  def create_reply
    @class_index =-1
    @class_index = params[:class_index] unless params[:class_index].nil?
    @micropost_follow_arr = FollowMicropost.where("user_id = ?",current_user.id).map(&:micropost_id)||[]
    reply = ReplyMicropost.new
    reply.content = params[:textarea]
    reply.micropost_id = params[:micropost_id]
    reply.sender_id = params[:teacher_id]
    reply.sender_types = Micropost::USER_TYPES[:TEACHER]
    reply.reciver_id = params[:micropost_user_id]
    reply.reciver_types = params[:micropost_user_type]
    if reply.save
      get_microposts
      #得到某个帖子的回复和帖子
      get_posts_and_replis params[:micropost_id]
      # 老师回复问答帖子
      Message.add_messages(reply, current_teacher.last_visit_class_id)
    end
  end
  def delete_micropost
    @micropost_follow_arr = FollowMicropost.where("user_id = ?",current_user.id).map(&:micropost_id)||[]
    reply = Micropost.find_by_id(params[:id])
    if reply&&reply.destroy
      get_microposts
      @temp='删除成功'
    else
      @temp='删除失败'
    end
  end
  def delete_micropost_reply
    @index = params[:index]
    @micropost = Micropost.find_by_id(params[:m_id])
    reply = ReplyMicropost.find_by_id(params[:id])
    if reply&&reply.destroy
      #get_microposts
      array = ReplyMicropost::get_microposts @micropost.id,1

      @reply = array[:reply_microposts]
      @reply_count = @reply.length
      @temp ='删除成功'
    else
      @temp='删除失败'
    end
  end

  def get_microposts
    @condition = params[:condtions]
    @condition = nil if params[:condtions]==""
    page = (params[:page].eql?("undefined") ? 1:params[:page])

    @scclass = SchoolClass.find(current_teacher.last_visit_class_id)
    @classmates = SchoolClass::get_classmates(@scclass)
    array = Micropost::get_microposts @scclass,page,@condition
    @microposts =array[:details_microposts]
  end

  def add_reply_page
    @index = params[:index].to_i
    @current_page = params[:current_page].to_i+1
    micropost_id = params[:micropost_id]
    @micropost = Micropost.find_by_id(micropost_id)
    @scclass = SchoolClass.find(current_teacher.last_visit_class_id)
    array = ReplyMicropost::get_microposts @micropost.id,@current_page
    @reply = array[:reply_microposts]
    @pages_count = array[:pages_count]
    @page = array[:page]
  end

  def particate_reply_show
    @index = params[:index]
    @types = params[:types].to_i
    get_posts_and_replis(params[:micropost_id])
  end

  #点赞
  def good_point
    reply_id = params[:reply_id]
    replymicropost = ReplyMicropost.find_by_id reply_id
    if replymicropost
      student = Student.find_by_user_id replymicropost.sender_id
      if replymicropost.praise.nil? || replymicropost.praise == 0
        replymicropost.update_attributes(:praise => ReplyMicropost::PRAISE[:KUDOS])
        ArchivementsRecord.update_archivements student, current_school_class, ArchivementsRecord::TYPES[:KUDOS]
        status = 1
        notice = "已赞！"
      else
        replymicropost.update_attributes(:praise => ReplyMicropost::PRAISE[:NOKUDOS])
        archivement =  ArchivementsRecord.find_by_student_id_and_school_class_id_and_archivement_types(student.id,current_school_class.id, ArchivementsRecord::TYPES[:KUDOS])
        if archivement.nil?
          archivement = ArchivementsRecord.create(:student_id => student.id,
            :school_class_id => current_school_class.id,
            :archivement_types => ArchivementsRecord::TYPES[:KUDOS],
            :archivement_score => 0)
        else
          if(archivement.archivement_score.to_i>=10)
            archivement.update_attributes(:archivement_score =>(archivement.archivement_score.to_i-10))
          else
            archivement.update_attributes(:archivement_score =>0)
          end
        end
        status = 2
        notice = "赞已取消！"
      end
    else
      status = 0
      notice = '回复不存在！'
    end
    render :json => {:status => status,:notice=> notice}
  end
end
