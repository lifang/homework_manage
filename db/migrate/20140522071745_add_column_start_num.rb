class AddColumnStartNum < ActiveRecord::Migration
	def change
		add_column :students, :star_num, :integer, :default => 0
		add_column :record_details, :star_num, :integer, :default => 0
	end	
end
