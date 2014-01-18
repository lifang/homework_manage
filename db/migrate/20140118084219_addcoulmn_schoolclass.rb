class AddcoulmnSchoolclass < ActiveRecord::Migration
  def change
    add_column :school_classes, :teaching_material_id, :integer
    add_index :school_classes, :teaching_material_id
  end
end
