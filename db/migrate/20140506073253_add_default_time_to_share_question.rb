class AddDefaultTimeToShareQuestion < ActiveRecord::Migration
  def change
    change_column :share_questions, :questions_time, :integer, :default => 180
  end
end
