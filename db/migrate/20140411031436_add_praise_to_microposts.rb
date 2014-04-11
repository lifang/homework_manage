class AddPraiseToMicroposts < ActiveRecord::Migration
  def change
    add_column :reply_microposts, :praise, :integer
  end
end
