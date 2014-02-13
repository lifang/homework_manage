#encoding: utf-8
class Message < ActiveRecord::Base
  attr_protected :authentications
  belongs_to :user
  belongs_to :micropost
  STATUS = {:NOMAL => 0, :READED => 1} #未阅读 0  已阅读
  PER_PAGE = 10
  def self.add_messages(micropost_id, reciver_id, reciver_types, sender_id, 
      sender_types, content, school_class_id)
    sender = User.find_by_id sender_id.to_i
    micropost = Micropost.find_by_id micropost_id.to_i
    count_msg = 0
    if sender
      unless sender_id.to_i == reciver_id.to_i or sender_id.to_i == micropost.user_id
        count_msg += 1
        m_content = "[[" + sender.name + "]]回复了您的消息：;||;" + content
        Message.create(:user_id => reciver_id, :content => m_content, :micropost_id => micropost_id,
          :school_class_id => school_class_id, :status => STATUS[:NOMAL], :sender_id => sender.id)
      end
      follow_microposts = FollowMicropost.find_all_by_micropost_id(micropost_id.to_i)
      follow_users = follow_microposts.collect {|i| i.user_id }
      if count_msg != 0 &&  follow_users.include?(reciver_id.to_i)
        e_content = "[[" + sender.name + "]]回复了您：;||;" + content
        Message.create(:user_id => reciver_id, :content => e_content, :micropost_id => micropost_id,
                       :school_class_id => school_class_id, :status => STATUS[:NOMAL], :sender_id => sender.id)
      end
      if follow_microposts.any?
          follow_users.each do |u_id|
            unless u_id == reciver_id.to_i
                f_content = "[[" + sender.name + "]]回复了您关注的消息：;||;" + content
                Message.create(:user_id => u_id, :content => f_content, :micropost_id => micropost_id,
                  :school_class_id => school_class_id, :status => STATUS[:NOMAL], :sender_id => sender.id)
            end
          end
      end
    end
  end

  #获取群我的当前班级的的消息
  def self.get_my_messages school_class, user_id
    messages = Message.joins('LEFT JOIN users u ON messages.sender_id = u.id').
      select("messages.id, messages.content, messages.user_id, messages.created_at, u.name sender_name,
     u.avatar_url sender_avatar_url, messages.micropost_id ").
      order("messages.created_at DESC").
      where("user_id = ? and school_class_id = ? and status = ?", user_id, school_class.id,
      Message::STATUS[:NOMAL])

  end
end
