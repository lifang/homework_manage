class AddColumnAliasNameToStudents < ActiveRecord::Migration
  def change
    add_column :students, :alias_name, :string
  end
end
