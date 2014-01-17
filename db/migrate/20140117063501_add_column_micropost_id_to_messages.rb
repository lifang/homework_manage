class AddColumnMicropostIdToMessages < ActiveRecord::Migration
  def change
    add_index :messages, :micropost_id
  end
end
