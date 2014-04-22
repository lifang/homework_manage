class RenameColumnClassIdFromSchoolClassStudentRalastions < ActiveRecord::Migration
  def up
    rename_column :school_class_student_ralastions, :class_id, :school_class_id
  end

  def down
    rename_column :school_class_student_ralastions, :school_class_id, :class_id
  end
end
