class CreateShareBranchQuestions < ActiveRecord::Migration
  def change
    create_table :share_branch_questions do |t|
      t.string :content
      t.integer :types
      t.integer :share_question_id
      t.string :resource_url
      t.timestamps
    end
  end
end
