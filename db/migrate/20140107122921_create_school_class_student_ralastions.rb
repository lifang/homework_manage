class CreateSchoolClassStudentRalastions < ActiveRecord::Migration
  def change
    create_table :school_class_student_ralastions do |t|
      t.integer :student_id
      t.integer :class_id
      t.timestamps
    end
    add_index :school_class_student_ralastions , :class_id
    add_index :school_class_student_ralastions , :student_id
  end
end
