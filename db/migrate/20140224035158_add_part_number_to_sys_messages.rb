class AddPartNumberToSysMessages < ActiveRecord::Migration
  def change
    add_column :sys_messages, :status, :integer
  end
end
