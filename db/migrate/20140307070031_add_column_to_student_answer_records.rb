class AddColumnToStudentAnswerRecords < ActiveRecord::Migration
  def change
    add_column :student_answer_records, :average_correct_rate, :integer
    add_column :student_answer_records, :average_complete_rate, :integer
  end
end
