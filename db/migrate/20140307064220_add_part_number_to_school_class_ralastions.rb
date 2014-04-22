class AddPartNumberToSchoolClassRalastions < ActiveRecord::Migration
  def change
    add_column :school_class_student_ralastions, :tag_id, :integer
    add_index :school_class_student_ralastions, :tag_id
  end
end
