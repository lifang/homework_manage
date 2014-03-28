class AddReferencedCountToShareQuestions < ActiveRecord::Migration
  def change
    add_column :share_questions, :referenced_count, :integer, :default => 0  #被引用次数
  end
end