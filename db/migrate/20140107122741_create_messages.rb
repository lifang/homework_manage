class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.integer :student_id
      t.string :content
      t.integer :school_class_id
      t.integer :status
      t.timestamps
    end
    add_index :messages , :school_class_id
  end
end
