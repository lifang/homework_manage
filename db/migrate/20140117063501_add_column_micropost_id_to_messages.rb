class AddColumnMicropostIdToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :micropost_id, :integer
    add_index :messages, :micropost_id
  end
end
