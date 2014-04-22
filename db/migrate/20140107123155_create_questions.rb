class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.string :name
      t.integer :types
      t.integer :question_package_id
      t.timestamps
    end
     add_index :questions , :question_package_id
  end
end
