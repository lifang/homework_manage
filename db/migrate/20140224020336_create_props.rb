class CreateProps < ActiveRecord::Migration
  def change
    create_table :props do |t|
      t.string :name
      t.integer :types
      t.string :description

      t.timestamps
    end
  end
end
