class CreateTaskMessages < ActiveRecord::Migration
  def change
    create_table :task_messages do |t|
      t.integer :school_class_id
      t.string :content
      t.datetime :period_of_validity
      t.integer :status
      t.timestamps
    end
    add_index :task_messages, :school_class_id
  end
end
