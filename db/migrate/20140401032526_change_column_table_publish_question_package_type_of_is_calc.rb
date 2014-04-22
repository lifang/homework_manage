class ChangeColumnTablePublishQuestionPackageTypeOfIsCalc < ActiveRecord::Migration
  def change
    change_column :publish_question_packages, :is_calc, :boolean, :default => false
  end
end
