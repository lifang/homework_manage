class RemoveColumnFromKnowledgesCard < ActiveRecord::Migration
  def up
    remove_column :knowledges_cards, :card_tag_id
    remove_index :knowledges_cards, :card_tag_id
  end

  def down
    add_column :knowledges_cards, :card_tag_id, :integer
    add_index :knowledges_cards, :card_tag_id
  end
end
