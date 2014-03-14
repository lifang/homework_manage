class AddDefatutValueToPublishQuestionPackage < ActiveRecord::Migration
  def change
    change_column_default :publish_question_packages, :tag_id, 0
  end
end
