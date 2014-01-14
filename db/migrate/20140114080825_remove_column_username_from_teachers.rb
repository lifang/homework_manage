class RemoveColumnUsernameFromTeachers < ActiveRecord::Migration
  def up
    remove_column :teachers, :username
  end

  def down
    add_column :teachers, :username, :string
  end
end
