class AddPartNumberToMicroposts < ActiveRecord::Migration
  def change
    add_column :microposts, :follow_micropost_count, :integer
  end
end
