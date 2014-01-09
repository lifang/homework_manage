class ChangTableTMandSar < ActiveRecord::Migration
  def change
    add_column :task_messages, :publish_question_package_id, :integer
    add_column :student_answer_records, :publish_question_package_id, :integer
  end
end
