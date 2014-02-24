class AddPartNumberTopublishQuestionPackages < ActiveRecord::Migration
  def change
    add_column :publish_question_packages, :tag_id, :integer
  end
end
