class AddColumnQuestionIdToShareQuestions < ActiveRecord::Migration
  def change
  	add_column :share_questions, :question_id, :integer #大题id
  end
end
