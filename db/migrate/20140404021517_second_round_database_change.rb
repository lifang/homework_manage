class SecondRoundDatabaseChange < ActiveRecord::Migration
  def change

    #创建科目表
    create_table :courses do |t|
      t.string :name
      t.boolean :status, :default => false  #删除 未删除
    end
    add_index :courses, :name

    #创建学校表
    create_table :schools do |t|
      t.string :name
      t.integer :students_count  #学生配额
      t.boolean :status, :default => false  #删除 未删除
    end
    add_index :schools, :name

    #教书表里面加教材外键，学校外键
    add_column :teachers, :teaching_material_id, :integer
    add_column :teachers, :school_id, :integer

    #教材表里面加 科目外键
    add_column :teaching_materials, :course_id, :integer
  end
end
