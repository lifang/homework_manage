class AddCellIdAndEpisodeIdToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :cell_id, :integer
    add_column :questions, :episode_id, :integer
  end
end
