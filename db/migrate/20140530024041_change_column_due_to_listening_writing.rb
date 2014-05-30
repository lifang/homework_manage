class ChangeColumnDueToListeningWriting < ActiveRecord::Migration
  def change
  	add_column :teaching_materials, :if_public, :boolean, :default => false  # false表示教材默认为不公开
  	add_column :branch_questions, :translation, :string  
  	add_column :school_classes, :types, :integer, :default => 0 # 0表示默认为超级作业本的班级，不是听写练习的班级
  	add_column :share_branch_questions, :translation, :string
  	add_column :courses, :types, :integer, :default => 0  # 0表示默认为超级作业本的科目，不是听写练习的科目
  end	
end
