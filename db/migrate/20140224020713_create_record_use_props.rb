class CreateRecordUseProps < ActiveRecord::Migration
  def change
    create_table :record_use_props do |t|
      t.integer :user_prop_relation_id
      t.integer :branch_question_id

      t.timestamps
    end
    add_index :record_use_props, :user_prop_relation_id
    add_index :record_use_props, :branch_question_id
  end
end
