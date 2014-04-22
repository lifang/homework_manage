class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :name
      t.integer :school_class_id

      t.timestamps
    end
    add_index :tags, :school_class_id
  end
end
