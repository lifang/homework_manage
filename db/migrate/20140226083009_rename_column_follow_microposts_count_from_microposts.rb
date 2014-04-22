class RenameColumnFollowMicropostsCountFromMicroposts < ActiveRecord::Migration
  def up
    rename_column :microposts, :follow_micropost_count, :follow_microposts_count
  end

  def down
    rename_column :microposts, :follow_microposts_count, :follow_micropost_count
  end
end
