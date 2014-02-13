class ShareQuestionsController < ApplicationController
  #显示分享题库中的某一题及小题
  def view
    @question = ShareQuestion.find_by_id(params[:share_question_id].to_i)
    @branch_questions = @question.share_branch_questions
  end
end
