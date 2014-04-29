class CreateTableShareQuestionPackages < ActiveRecord::Migration
  def change
    create_table :share_question_packages do |t|
      t.string  :name
      t.integer :cell_id
      t.integer :episode_id
      t.integer :created_by  #创建快捷题包的题库管理员（teacher_id）
      
      t.timestamps
    end
  end
end
