class AddUserIdToShareQuestions < ActiveRecord::Migration
  def change
    add_column :share_questions, :user_id, :integer  #分享题目的作者
  end
end
