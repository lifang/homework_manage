#encoding: utf-8
class AddVeriCodeToStudents < ActiveRecord::Migration
  def change
    add_column :students, :veri_code, :integer    #导入的学生的批次
  add_index :students, :veri_code
  end

end
