class CreateSysMessages < ActiveRecord::Migration
  def change
    create_table :sys_messages do |t|
      t.integer :school_class_id
      t.integer :student_id
      t.string :content

      t.timestamps
    end
    add_index :sys_messages, :student_id
    add_index :sys_messages, :school_class_id
  end
end
