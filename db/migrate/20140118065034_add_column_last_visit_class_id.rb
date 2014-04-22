class AddColumnLastVisitClassId < ActiveRecord::Migration
  def up
    add_column :teachers, :last_visit_class_id, :integer
  end

  def down
    remove_column :teachers, :last_visit_class_id, :integer
  end
end
