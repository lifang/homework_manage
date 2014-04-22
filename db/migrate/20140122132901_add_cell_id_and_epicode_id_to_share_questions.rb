class AddCellIdAndEpicodeIdToShareQuestions < ActiveRecord::Migration
  def change
    add_column :share_questions, :cell_id, :integer
    add_column :share_questions, :episode_id, :integer
  end
end
