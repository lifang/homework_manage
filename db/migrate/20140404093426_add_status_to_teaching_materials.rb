class AddStatusToTeachingMaterials < ActiveRecord::Migration
  def change
    add_column :teaching_materials, :status, :boolean, :default => true
  end
end
