class AddUsedSchoolCountsToSchool < ActiveRecord::Migration
  def change
    add_column :school, :used_school_counts, :integer  #已经使用的配额
  end
end
