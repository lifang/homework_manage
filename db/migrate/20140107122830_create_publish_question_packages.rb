class CreatePublishQuestionPackages < ActiveRecord::Migration
  def change
    create_table :publish_question_packages do |t|
      t.integer :question_package_id
      t.integer :status
      t.integer :school_class_id
      t.string :question_packages_url
      t.datetime :start_time
      t.datetime :end_time
      t.timestamps
    end
    add_index :publish_question_packages , :question_package_id
  end
end
