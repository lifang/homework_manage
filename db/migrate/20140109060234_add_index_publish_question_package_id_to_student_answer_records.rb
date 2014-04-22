class AddIndexPublishQuestionPackageIdToStudentAnswerRecords < ActiveRecord::Migration
  def change
    add_index :student_answer_records, :publish_question_package_id
  end
end
