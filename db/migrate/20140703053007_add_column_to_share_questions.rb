class AddColumnToShareQuestions < ActiveRecord::Migration
  def change
  	add_column :share_questions, :teaching_material_id, :integer #教材id
  end
end
