class ChangecoloumOfreplyMicroposts < ActiveRecord::Migration
  def change
    change_column :reply_microposts, :created_at, :datetime
  end
end
