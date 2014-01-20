#encoding: utf-8
class MessagesController < ApplicationController
  def index
    @class_id = params[:school_class_id].to_i
    @messages = Message.paginate_by_sql(["select s.avatar_url url,m.id,m.content,m.created_at,m.micropost_id,m.user_id
        from teachers t inner join users u on t.user_id=u.id
        inner join messages m on u.id=m.user_id
        inner join users s on m.sender_id=s.id
        where t.id=? and m.status=? and m.school_class_id=? order by m.created_at desc",
        session[:teacher_id], Message::STATUS[:NOMAL], @class_id], :page => params[:page], :per_page => 1) if session[:teacher_id]
    
  end

  def destroy
    Message.transaction do
      mess = Message.find_by_id(params[:id].to_i)
      mess.update_attribute("status", Message::STATUS[:READED])
      flash[:notice] = "操作成功!"
      redirect_to messages_path
    end
  end

  def check_micropost
    class_id = params[:school_class_id].to_i
    uid = params[:uid].to_i
    mid = params[:mid].to_i
    query_sql = "select m.id micropost_id, m.user_id, m.user_types, m.content, m.created_at,
                m.reply_microposts_count, u.name, u.avatar_url  from microposts m
                inner join users u on u.id = m.user_id where school_class_id = ? and m.user_id=?
                order by m.created_at desc"
    query_m = Micropost.paginate_by_sql([query_sql, class_id, uid], :per_page => Micropost::PER_PAGE, :page => 1)
    flag1 = query_m.inject(false){|f,qm|
      if qm.micropost_id == mid
        f = true
      end;
      f
    }
    if flag1 == true
      redirect_to "/school_classes/#{class_id}/main_pages?condtions=#{uid}&init_mid=#{mid}"
    else
      single_micropost = Micropost.find_by_id(mid)
      if single_micropost.nil?
        flash[:notice] = "该状态不存在或已删除!"
        redirect_to "/school_classes/#{class_id}/messages"
      else
        redirect_to "/school_classes/#{class_id}/main_pages?condtions=#{uid}&init_mid=#{mid}&single_m=1"
      end
    end
  end
end