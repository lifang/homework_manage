class CreateTableAdminMessage < ActiveRecord::Migration
  def change
    create_table :admin_messages do |t|  #系统管理员与学校管理员之间发送消息
      t.integer :sender_id
      t.integer :receiver_id
      t.string :content
    end
    add_index :admin_messages, :receiver_id
  end
end
