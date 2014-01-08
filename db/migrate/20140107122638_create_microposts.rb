class CreateMicroposts < ActiveRecord::Migration
  def change
    create_table :microposts do |t|
      t.integer :user_id
      t.integer :user_types
      t.string :content
      t.integer :school_class_id
      t.timestamps
    end
    add_index :microposts , :school_class_id
  end
end
