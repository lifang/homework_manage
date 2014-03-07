class AddPartNumberToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :questions_time, :integer
  end
end
