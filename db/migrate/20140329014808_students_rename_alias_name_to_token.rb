class StudentsRenameAliasNameToToken < ActiveRecord::Migration
  def change
    rename_column :students, :alias_name, :token  #ios推送标志
  end
end
