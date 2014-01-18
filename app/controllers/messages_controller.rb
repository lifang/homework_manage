#encoding: utf-8
class MessagesController < ApplicationController
  def index
    @messages = Message.paginate_by_sql(["select s.avatar_url url,m.id,m.content,m.created_at,m.micropost_id
        from teachers t inner join users u on t.user_id=u.id
        inner join messages m on u.id=m.user_id
        inner join users s on m.sender_id=s.id
        where t.id=? and m.status=? order by m.created_at desc", 
        session[:teacher_id], Message::STATUS[:NOMAL]], :page => params[:page], :per_page => 1)
    
  end

  def destroy
    Message.transaction do
      mess = Message.find_by_id(params[:id].to_i)
      mess.update_attribute("status", Message::STATUS[:READED])
      flash[:notice] = "操作成功!"
      redirect_to messages_path
    end
  end
end