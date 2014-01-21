class AddIfSharedToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :if_shared, :boolean  #题目只能分享一次
  end
end
