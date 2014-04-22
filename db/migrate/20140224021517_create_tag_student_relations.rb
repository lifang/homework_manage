class CreateTagStudentRelations < ActiveRecord::Migration
  def change
    create_table :tag_student_relations do |t|
      t.integer :tag_id
      t.integer :student_id

      t.timestamps
    end
    add_index :tag_student_relations, :tag_id
    add_index :tag_student_relations, :student_id
  end
end
