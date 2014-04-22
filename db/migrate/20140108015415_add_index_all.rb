class AddIndexAll < ActiveRecord::Migration
  def change
    add_index :microposts, :user_id
    add_index :reply_microposts, :sender_id
    add_index :reply_microposts, :reciver_id
    add_index :messages, :student_id
    add_index :publish_question_packages, :school_class_id
    add_index :student_answer_records, :student_id
    add_index :student_answer_records, :question_package_id
    add_index :share_questions, :question_package_type_id
    add_index :share_branch_questions, :share_question_id
  end
end
