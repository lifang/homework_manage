class AddColumnIsCalcToPublishQuestionPackages < ActiveRecord::Migration
  def change
    add_column :publish_question_packages, :is_calc, :integer, :default => 0
  end
end
