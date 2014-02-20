#encoding: utf-8
include MicropostsHelper
class MessagesController < ApplicationController
  before_filter :sign?
  def index
    @class_id = params[:school_class_id].to_i
    @messages = Message.paginate_by_sql(["select s.avatar_url url,m.id,m.content,m.created_at,m.micropost_id,m.user_id
        from teachers t inner join users u on t.user_id=u.id
        inner join messages m on u.id=m.user_id
        inner join users s on m.sender_id=s.id
        where t.id=? and m.status=? and m.school_class_id=? order by m.created_at desc",
        cookies[:teacher_id].to_i, Message::STATUS[:NOMAL], @class_id], :page => params[:page],
      :per_page => Message::PER_PAGE) if cookies[:teacher_id]
    
  end

  def destroy
    Message.transaction do
      mess = Message.find_by_id(params[:id].to_i)
      mess.update_attribute("status", Message::STATUS[:READED])
      flash[:notice] = "操作成功!"
      redirect_to school_class_messages_path(params[:school_class_id])
    end
  end

  def check_micropost
    class_id = params[:school_class_id].to_i
    uid = params[:uid].to_i
    mid = params[:mid].to_i
    mess_id = params[:mess_id]
    message = Message.find_by_id(mess_id)
    message.update_attribute("status", Message::STATUS[:READED]) if message
    redirect_to "/school_classes/#{class_id}/main_pages?condtions=#{uid}&init_mid=#{mid}"
  end
  def new_message_remind
    message = "1111111111ee11"
    receivervalue ="d"
    jpush_parameter message,receivervalue
    render :nothing => true
  end
end