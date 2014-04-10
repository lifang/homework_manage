class AddVeriCodeToStudents < ActiveRecord::Migration
  def change
    add_column :students, :veri_code, :integer
  add_index :students, :veri_code
  end

end
