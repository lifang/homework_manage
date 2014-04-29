class CreateCardTagKnowledgesCardRelations < ActiveRecord::Migration
  def change
    create_table :card_tag_knowledges_card_relations do |t|
      t.integer :card_tag_id
      t.integer :knowledges_card_id
      t.timestamps
    end
    add_index :card_tag_knowledges_card_relations, :card_tag_id
    add_index :card_tag_knowledges_card_relations, :knowledges_card_id
  end
end
