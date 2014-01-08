class CreateTeachers < ActiveRecord::Migration
  def change
    create_table :teachers do |t|
      t.string :username
      t.string :password
      t.string :name
      t.string :email
      t.integer :status
      t.string :avatar_url
      t.integer :types
      t.timestamps
    end
  end
end
