class CreateRecordDetails < ActiveRecord::Migration
  def change
    create_table :record_details do |t|
      t.integer :used_time
      t.integer :specified_time
      t.integer :question_types
      t.integer :correct_rate
      t.integer :score
      t.integer :is_complete
      t.integer :student_answer_record_id

      t.timestamps
    end
    add_index :record_details, :student_answer_record_id
  end
end
