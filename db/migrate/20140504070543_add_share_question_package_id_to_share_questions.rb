class AddShareQuestionPackageIdToShareQuestions < ActiveRecord::Migration
  def change
    add_column :share_questions, :share_question_package_id, :integer
  end
end
