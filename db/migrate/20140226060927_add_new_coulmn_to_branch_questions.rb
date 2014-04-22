class AddNewCoulmnToBranchQuestions < ActiveRecord::Migration
  def change
    add_column :branch_questions, :options, :string,:limit => 1000

    add_column :branch_questions, :answer, :string

  end
end
