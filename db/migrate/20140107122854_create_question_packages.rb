class CreateQuestionPackages < ActiveRecord::Migration
  def change
    create_table :question_packages do |t|
      t.string :name
      t.integer :school_class_id
      t.timestamps
    end
    add_index :question_packages , :school_class_id
  end
end
