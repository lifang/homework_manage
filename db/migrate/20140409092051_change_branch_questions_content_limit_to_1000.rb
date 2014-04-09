class ChangeBranchQuestionsContentLimitTo1000 < ActiveRecord::Migration
  def change
    change_column :branch_questions, :content, :string, :limit => 1000
  end
end
