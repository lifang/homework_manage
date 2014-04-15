class ChangeColumnTeacherIdFormSchoolClasses < ActiveRecord::Migration
  def change
  	change_column :school_classes, :teacher_id, :integer
  end
end
