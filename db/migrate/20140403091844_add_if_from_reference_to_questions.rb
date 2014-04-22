class AddIfFromReferenceToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :if_from_reference, :boolean, :default => false #引用来的题目不能被分享，加个字段判断
  end
end
