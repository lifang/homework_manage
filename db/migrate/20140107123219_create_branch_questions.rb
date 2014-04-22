class CreateBranchQuestions < ActiveRecord::Migration
  def change
    create_table :branch_questions do |t|
      t.string :content
      t.integer :types
      t.string :resource_url
      t.integer :question_id
      t.timestamps
    end
    add_index :branch_questions , :question_id
  end
end
