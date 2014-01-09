class AddColumnSchoolClassIdToStudentAnswerRecords < ActiveRecord::Migration
  def change
    add_column :student_answer_records, :school_class_id, :integer
    add_index :student_answer_records, :school_class_id
  end
end
