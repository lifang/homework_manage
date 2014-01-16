class AddColumnToPublishQuestionPackagesAndStudentAnswerRecords < ActiveRecord::Migration
  def change
    add_column :student_answer_records, :listening_answer_count, :integer
    add_column :student_answer_records, :reading_answer_count, :integer
    add_column :publish_question_packages, :listening_count, :integer
    add_column :publish_question_packages, :reading_count, :integer
  end
end
