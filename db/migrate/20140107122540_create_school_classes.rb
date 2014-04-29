class CreateSchoolClasses < ActiveRecord::Migration
  def change
    create_table :school_classes do |t|
      t.string :name
      t.string :verification_code
      t.datetime :period_of_validity
      t.integer :status
      t.string :teacher_id
    end
    add_index :school_classes, :teacher_id
  end
end
