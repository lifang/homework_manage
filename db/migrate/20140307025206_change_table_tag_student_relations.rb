class ChangeTableTagStudentRelations < ActiveRecord::Migration
  def up
    remove_index :tag_student_relations, :tag_id
    remove_index :tag_student_relations, :student_id
    rename_table :tag_student_relations, :branch_tags
    rename_column :branch_tags, :tag_id, :name
    rename_column :branch_tags, :student_id, :teacher_id
    change_column :branch_tags, :name, :string
    add_index :branch_tags, :teacher_id
  end

  def down
  end
end
