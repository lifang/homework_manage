class AddStatusAndTimestampsToAdminMessages < ActiveRecord::Migration
  def change
    add_column :admin_messages, :status, :boolean  #系统消息 状态，删除、未删除
    change_table :admin_messages do |t|
      t.timestamps
    end
  end
end
