class CreateKnowledgesCards < ActiveRecord::Migration
  def change
    create_table :knowledges_cards do |t|
      t.integer :card_bag_id
      t.integer :mistake_types
      t.integer :branch_question_id
      t.string :your_answer

      t.timestamps
    end
    add_index :knowledges_cards, :card_bag_id
    add_index :knowledges_cards, :branch_question_id
  end
end
