class ShareQuestionsController < ApplicationController
  #显示分享题库中的某一题及小题
  def view
    @question_pack = QuestionPackage.find_by_id params[:question_package_id].to_i
    @question = Question.find_by_id params[:question_id].to_i
    @share_question = ShareQuestion.find_by_id(params[:share_question_id].to_i)
    @branch_questions = @share_question.share_branch_questions
  end
end
