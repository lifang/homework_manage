class CreateAppVersions < ActiveRecord::Migration
  def change
    create_table :app_versions do |t|
      t.float :c_version
    end
    add_index :app_versions, :c_version
  end
end
