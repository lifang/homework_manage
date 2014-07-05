class AddColumnToQuestionPackage < ActiveRecord::Migration
  def change
  	add_column :question_packages, :que_pack_date, :datetime #题包的时间
  end
end
