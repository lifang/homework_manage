class CreateTeachingMaterials < ActiveRecord::Migration
  def change
    create_table :teaching_materials do |t|
      t.string :name
      t.timestamps
    end
  end
end
