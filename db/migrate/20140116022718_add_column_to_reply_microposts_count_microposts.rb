class AddColumnToReplyMicropostsCountMicroposts < ActiveRecord::Migration
  def change
    add_column :microposts, :reply_microposts_count, :integer
  end
end
