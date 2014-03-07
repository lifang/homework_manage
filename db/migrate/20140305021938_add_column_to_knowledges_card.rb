class AddColumnToKnowledgesCard < ActiveRecord::Migration
  def change
    add_column :knowledges_cards, :card_tag_id, :integer
    add_index :knowledges_cards, :card_tag_id
  end
end
