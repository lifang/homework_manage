class CreateShareQuestions < ActiveRecord::Migration
  def change
    create_table :share_questions do |t|
      t.string :name
      t.integer :types
      t.integer :question_package_type_id
      t.timestamps
    end
  end
end
