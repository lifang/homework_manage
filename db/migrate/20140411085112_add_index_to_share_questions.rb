class AddIndexToShareQuestions < ActiveRecord::Migration
  def change
    add_index :share_questions, :cell_id
    add_index :share_questions, :episode_id
  end
end
