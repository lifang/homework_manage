class AddColumnToTeachingMaterials < ActiveRecord::Migration
  def change
  	add_column :teaching_materials, :teacher_id, :integer #创建者的id
  end
end
