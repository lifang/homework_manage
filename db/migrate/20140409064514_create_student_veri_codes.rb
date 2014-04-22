#encoding: utf-8
class CreateStudentVeriCodes < ActiveRecord::Migration
  def change
    create_table :student_veri_codes do |t|
      t.integer :code
      t.timestamps
    end
  end
end
