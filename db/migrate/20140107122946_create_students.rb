class CreateStudents < ActiveRecord::Migration
  def change
    create_table :students do |t|
      t.string :name
      t.string :nickname
      t.string :avatar_url
      t.string :alias_name
      t.string :qq_uid
      t.integer :status
      t.integer :last_visit_class_id
      t.integer :register_status
      t.timestamps
    end
  end
end
