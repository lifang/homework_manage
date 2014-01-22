class CreateCells < ActiveRecord::Migration
  def change
    create_table :cells do |t|
      t.string :name
      t.integer :teaching_material_id
      t.timestamps
    end
  end
end
