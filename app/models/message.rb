#encoding: utf-8
class Message < ActiveRecord::Base
  extend MethodLibsHelper
  attr_protected :authentications
  belongs_to :user
  belongs_to :micropost
  STATUS = {:NOMAL => 0, :READED => 1} #0未阅读  1已阅读
  PER_PAGE = 10
  def self.add_messages(reply, school_class_id)
    micropost_id, reciver_id, reciver_types, sender_id, sender_types, content, reply_micropost_id = reply.micropost_id, reply.reciver_id, reply.reciver_types,reply.sender_id, reply.sender_types,reply.content, reply.id
    sender = User.find_by_id sender_id.to_i
    send_name = sender.try(:name) || ""
    micropost = Micropost.find_by_id micropost_id.to_i
    
    if_send = false  #发一种消息就行，不发其他类型的了
    have_sended_user_ids = []
    if sender
      teachers = Teacher.where("status = #{Teacher::STATUS[:YES]}")
      teachers_id = teachers.map(&:user_id)
      if sender_id.to_i != reciver_id.to_i && sender_id.to_i != micropost.user_id  #某学生发布的问答，老师或者其他同学回复他
        m1_content = "[[" + sender.name + "]]回复了您的消息：;||;" + content
        push_content = "#{send_name}：#{content}"
        if micropost.user_id == reciver_id.to_i
          if_send = true
          have_sended_user_ids << reciver_id.to_i
          student = Student.find_by_user_id reciver_id.to_i #直接发给楼主
          Message.create(:user_id => reciver_id, :content => m1_content, :micropost_id => micropost_id,
            :school_class_id => school_class_id, :status => STATUS[:NOMAL], :sender_id => sender.id,:reply_micropost_id => reply_micropost_id)
          push_after_reply_post push_content, teachers_id, reciver_id, school_class_id, student, reciver_types
        else
          have_sended_user_ids << micropost.user_id
          student = Student.find_by_user_id micropost.user_id #楼主的帖子下面，别人互相回复
          Message.create(:user_id => micropost.user_id, :content => m1_content, :micropost_id => micropost_id,
            :school_class_id => school_class_id, :status => STATUS[:NOMAL], :sender_id => sender.id,:reply_micropost_id => reply_micropost_id)
          push_after_reply_post push_content, teachers_id, micropost.user_id, school_class_id, student, reciver_types
        end
      end
      
      follow_microposts = FollowMicropost.find_all_by_micropost_id(micropost_id.to_i)  #关注此贴子的记录
      follow_users = follow_microposts.collect {|i| i.user_id }  #关注此贴子的所有人

     # if !if_send && !follow_users.include?(reciver_id.to_i) && sender_id.to_i != reciver_id.to_i
      if !if_send && sender_id.to_i != reciver_id.to_i
        m2_content = "[[" + send_name + "]]回复了您：;||;" + content
        push_content = "#{send_name}：#{content}"
        have_sended_user_ids << reciver_id.to_i
        student = Student.find_by_user_id reciver_id.to_i  #发给一个人
        Message.create(:user_id => reciver_id, :content => m2_content, :micropost_id => micropost_id,
          :school_class_id => school_class_id, :status => STATUS[:NOMAL], :sender_id => sender.id,:reply_micropost_id => reply_micropost_id)
        push_after_reply_post push_content, teachers_id, reciver_id, school_class_id, student, reciver_types
      end
      
      if follow_users.present?
        m3_content = "[[" + send_name + "]]回复了您关注的消息：;||;" + content
        push_content = "#{send_name}：#{content}"
        follow_users = follow_users - [sender_id.to_i]  if follow_users.include?(sender_id.to_i)  #发送者是关注者的过滤掉
        follow_users -= have_sended_user_ids #发送过的过滤掉
        
        follow_users.each do |u_id|   #发给关注问答的人
          unless sender_id.to_i == u_id
            student = Student.find_by_user_id u_id
            Message.create(:user_id => u_id, :content => m3_content, :micropost_id => micropost_id,
              :school_class_id => school_class_id, :status => STATUS[:NOMAL], :sender_id => sender.id,:reply_micropost_id => reply_micropost_id)
            push_after_reply_post push_content, teachers_id, reciver_id, school_class_id, student, reciver_types
          end
        end
      end
      
    end
  end

  #获取群我的当前班级的的消息
  def self.get_my_messages school_class, user_id
    messages = Message.joins('LEFT JOIN users u ON messages.sender_id = u.id').
      select("messages.id, messages.content, messages.user_id, DATE_FORMAT(messages.created_at, '%Y-%m-%d %H:%i:%S') as new_created_at, u.name sender_name,
     u.avatar_url sender_avatar_url, messages.micropost_id ").
      order("messages.created_at DESC").
      where("user_id = ? and school_class_id = ? and status = ?", user_id, school_class.id,
      Message::STATUS[:NOMAL])

  end

  #获取我的信息
  def self.get_mine_messages school_class, user_id,page
    page = 1 if page.eql?(0)
    messages = Message.joins('LEFT JOIN users u ON messages.sender_id = u.id').
      joins("INNER JOIN reply_microposts rm on rm.id = messages.reply_micropost_id").
      select("messages.id, messages.content, messages.user_id, DATE_FORMAT(messages.created_at, '%Y-%m-%d %H:%i:%S') as new_created_at, u.name sender_name,
     u.avatar_url sender_avatar_url, messages.micropost_id ,rm.sender_id reciver_id,rm.sender_types reciver_types").
      order("messages.created_at DESC").
      where("user_id = ? and school_class_id = ? and status = ?", user_id, school_class.id,
      Message::STATUS[:NOMAL]).paginate(:page => page, :per_page => PER_PAGE)
  end
end