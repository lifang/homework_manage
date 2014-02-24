class CreateUserPropRelations < ActiveRecord::Migration
  def change
    create_table :user_prop_relations do |t|
      t.integer :student_id
      t.integer :prop_id
      t.integer :user_prop_num
      t.integer :school_class_id

      t.timestamps
    end
    add_index :user_prop_relations, :student_id
    add_index :user_prop_relations, :prop_id
    add_index :user_prop_relations, :school_class_id
  end
end
