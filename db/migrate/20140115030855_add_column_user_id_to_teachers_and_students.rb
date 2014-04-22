class AddColumnUserIdToTeachersAndStudents < ActiveRecord::Migration
  def change
    add_column :teachers, :user_id, :integer
    add_column :students, :user_id, :integer
    add_index :teachers, :user_id
    add_index :students, :user_id
  end
end
