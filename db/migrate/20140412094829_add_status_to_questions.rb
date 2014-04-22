class AddStatusToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :status, :boolean, :default => true  #题目状态 0删除 1正常
  end
end
