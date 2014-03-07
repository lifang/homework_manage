class CreateSbranchBranchTagRelations < ActiveRecord::Migration
  def change
    create_table :sbranch_branch_tag_relations do |t|
      t.integer :share_branch_question_id
      t.integer :branch_tag_id
      t.timestamps
    end
    add_index :sbranch_branch_tag_relations, :share_branch_question_id
    add_index :sbranch_branch_tag_relations, :branch_tag_id
  end
end
