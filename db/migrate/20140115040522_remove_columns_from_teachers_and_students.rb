class RemoveColumnsFromTeachersAndStudents < ActiveRecord::Migration
  def up
    remove_column :teachers, :name
    remove_column :teachers, :avatar_url
    remove_column :students, :name
    remove_column :students, :avatar_url
  end

  def down
    add_column :teachers, :name, :string
    add_column :teachers, :avatar_url, :string
    add_column :students, :name, :string
    add_column :students, :avatar_url, :string
  end
end

