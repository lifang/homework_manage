class UpdateCulumnToStudent < ActiveRecord::Migration
  def change
    change_column :students, :active_status, :integer, :limit =>1
  end
end
