class AddUsedSchoolCountsToSchool < ActiveRecord::Migration
  def change
    add_column :schools, :used_school_counts, :integer  #已经使用的配额
  end
end
