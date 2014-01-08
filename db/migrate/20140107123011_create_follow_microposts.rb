class CreateFollowMicroposts < ActiveRecord::Migration
  def change
    create_table :follow_microposts do |t|
      t.integer :student_id
      t.integer :micropost_id
      t.timestamps
    end
    add_index :follow_microposts , :student_id
    add_index :follow_microposts , :micropost_id
  end
end
