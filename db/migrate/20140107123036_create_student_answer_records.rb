class CreateStudentAnswerRecords < ActiveRecord::Migration
  def change
    create_table :student_answer_records do |t|
      t.integer :student_id
      t.integer :question_package_id
      t.integer :status
      t.string :answer_file_url
      t.timestamps
    end
  end
end
