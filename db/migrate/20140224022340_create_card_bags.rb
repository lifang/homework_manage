class CreateCardBags < ActiveRecord::Migration
  def change
    create_table :card_bags do |t|
      t.integer :school_class_id
      t.integer :student_id
      t.integer :knowledges_cards_count

      t.timestamps
    end
    add_index :card_bags, :student_id
    add_index :card_bags, :school_class_id
  end
end
