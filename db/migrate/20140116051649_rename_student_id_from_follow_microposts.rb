class RenameStudentIdFromFollowMicroposts < ActiveRecord::Migration
  def up
    remove_index :follow_microposts, :student_id
    rename_column :follow_microposts, :student_id, :user_id
    add_index :follow_microposts, :user_id
  end

  def down
    remove_index :follow_microposts, :user_id
    rename_column :follow_microposts, :user_id, :student_id
    add_index :follow_microposts, :student_id
  end
end
