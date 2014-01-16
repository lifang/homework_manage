class RenameColumnStudentIdFromMessages < ActiveRecord::Migration
  def up
    remove_index :messages, :student_id
    rename_column :messages, :student_id, :user_id
    add_index :messages, :user_id
  end

  def down
    remove_index :messages, :user_id
    rename_column :messages, :user_id, :student_id
    add_index :messages, :student_id
  end
end
