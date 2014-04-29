class AddDatetimeNumberToSchools < ActiveRecord::Migration
  def change
    add_column :schools, :created_at, :datetime
    add_column :schools, :updated_at, :datetime
  end
end
