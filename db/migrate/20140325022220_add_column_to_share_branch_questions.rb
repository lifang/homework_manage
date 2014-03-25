class AddColumnToShareBranchQuestions < ActiveRecord::Migration
  def change
    add_column :share_questions, :questions_time, :integer
    add_column :share_questions, :full_text, :text

    add_column :share_branch_questions, :options, :string,:limit => 1000
    add_column :share_branch_questions, :answer, :string
  end
end
