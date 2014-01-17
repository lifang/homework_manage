class RemoveColumnAliasNameFromTeachersAndStudents < ActiveRecord::Migration
  def up
    remove_column :students, :alias_name
  end

  def down
    add_column  :students, :alias_name, :string
  end
end
