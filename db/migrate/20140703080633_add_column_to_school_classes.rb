class AddColumnToSchoolClasses < ActiveRecord::Migration
  def change
  	add_column :school_classes, :if_public, :boolean #教材状态:是否公开
  end
end
