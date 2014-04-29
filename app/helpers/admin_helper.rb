#encoding: utf-8
module AdminHelper
  #获取未读信息提示
  def get_admin_unread_messes
    @unread_messes = AdminMessage.where(["receiver_id = ? and (status is null or status != ?)",
        cookies[:teacher_id].to_i, AdminMessage::STATUS[:READED]]).order("created_at desc")
  end

end