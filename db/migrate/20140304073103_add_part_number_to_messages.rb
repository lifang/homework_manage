class AddPartNumberToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :reply_micropost_id, :integer
    add_index :messages, :reply_micropost_id
  end
end
