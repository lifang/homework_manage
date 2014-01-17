#encoding: utf-8
class Message < ActiveRecord::Base
  attr_protected :authentications
  belongs_to :user
  STATUS = {:NOMAL => 0, :READED => 1} #未阅读 0  已阅读
  
  def self.add_messages(micropost_id, reciver_id, reciver_types, sender_id, 
      sender_types, content, school_class_id)
    sender = User.find_by_id sender_id.to_i
    if sender
      m_content = "[[" + sender.name + "]]回复了您的消息：;||;" + content
      Message.create(:user_id => reciver_id, :content => m_content, 
        :school_class_id => school_class_id, :status => STATUS[:NOMAL])
      follow_microposts = FollowMicropost.find_all_by_micropost_id(micropost_id.to_i)
      if follow_microposts.any?
        follow_users = follow_microposts.collect {|i| i.user_id }
        follow_users.each do |u_id|
          f_content = "[[" + sender.name + "]]回复了您关注的消息：;||;" + content
          Message.create(:user_id => u_id, :content => f_content, 
          :school_class_id => school_class_id, :status => STATUS[:NOMAL])
        end
      end
    end    
  end

  #获取群我的当前班级的的消息
  def self.get_my_messages school_class, user_id
    #messages = Message.where("user_id = ? and school_class_id = ?",user_id, school_class.id)
    messages = Message.order("created_at DESC").
        where("user_id = ? and school_class_id = ? and status = ?", user_id, school_class.id,
              Message::STATUS[:NOMAL] )

  end
end
