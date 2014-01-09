class AddColumnPublishQuestionPackagesIdToTaskMessages < ActiveRecord::Migration
  def change
    add_column :task_messages, :publish_question_package_id, :integer
    add_index :task_messages, :publish_question_package_id
  end
end
