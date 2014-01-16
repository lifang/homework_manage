class AddColumnToReplyMicropostsCountMicroposts < ActiveRecord::Migration
  def change
    add_column :microposts, :reply_microposts_count, :integer, :default => 0
  end
end
