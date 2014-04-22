class CreateQuestionPackageTypes < ActiveRecord::Migration
  def change
    create_table :question_package_types do |t|
      t.string :name
      t.string :teaching_material_name
      t.string :teaching_material_isbn
      t.string :teaching_material_pulisher
      t.timestamps
    end
  end
end
