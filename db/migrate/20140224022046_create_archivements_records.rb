class CreateArchivementsRecords < ActiveRecord::Migration
  def change
    create_table :archivements_records do |t|
      t.integer :school_class_id
      t.integer :student_id
      t.integer :archivement_score
      t.integer :archivement_types

      t.timestamps
    end
    add_index :archivements_records, :school_class_id
    add_index :archivements_records, :student_id
  end
end
