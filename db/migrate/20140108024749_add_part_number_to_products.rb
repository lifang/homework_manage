class AddPartNumberToProducts < ActiveRecord::Migration
  def change
    add_column :school_classes, :created_at, :datetime
    add_column :school_classes, :updated_at, :datetime
  end
end
