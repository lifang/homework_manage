#encoding: utf-8
class AddSchoolIdToStudents < ActiveRecord::Migration
  def change
    add_column :students, :school_id, :integer

  end
end
