class AddColumnPublishQuestionPackageIdToStudentAnswerRecords < ActiveRecord::Migration
  def change
    add_column :student_answer_records, :publish_question_package_id, :integer
  end
end
