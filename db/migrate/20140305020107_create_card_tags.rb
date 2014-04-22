class CreateCardTags < ActiveRecord::Migration
  def change
    create_table :card_tags do |t|
      t.string :name
      t.integer :card_bag_id
      t.timestamps
    end
    add_index :card_tags, :card_bag_id
  end
end
