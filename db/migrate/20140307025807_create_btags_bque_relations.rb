class CreateBtagsBqueRelations < ActiveRecord::Migration
  def change
    create_table :btags_bque_relations do |t|
      t.integer :branch_question_id
      t.integer :branch_tag_id
      t.timestamps
    end
    add_index :btags_bque_relations, :branch_question_id
    add_index :btags_bque_relations, :branch_tag_id
  end
end
