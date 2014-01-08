class CreateReplyMicroposts < ActiveRecord::Migration
  def change
    create_table :reply_microposts do |t|
      t.integer :sender_id
      t.integer :sender_types
      t.string :content
      t.integer :micropost_id
      t.integer :reciver_id
      t.integer :reciver_types
      t.timestamps
    end
    add_index :reply_microposts , :micropost_id
  end
end
