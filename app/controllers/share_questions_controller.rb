class ShareQuestionsController < ApplicationController
  #显示分享题库中的某一题及小题
  def view
    @question_pack = QuestionPackage.find_by_id params[:question_package_id].to_i
    @question = Question.find_by_id params[:question_id].to_i
    @share_question = ShareQuestion.find_by_id(params[:share_question_id].to_i)
    @branch_questions = @share_question.share_branch_questions
  end

  # 列出引用的题目
  def list_questions_by_type
    question_type, cell_id, episode_id, question_pack_id = params[:types].to_i,params[:cell_id], params[:episode_id], params[:question_package_id]

    @share_questions = ShareQuestion.share_questions(cell_id, episode_id, question_type, "desc", 1)
    if @share_questions.present?
      status, @question, @question_pack = QuestionPackage.create_new_question_pack_and_ques(question_pack_id,cell_id,episode_id,question_type, status)
      if status
        render :partial =>"questions/new_reference"
      else
        render :text => "-1" #"保存失败"
      end
    else
      render :text => "-2" #"该单元下没有题目可以引用"
    end
  end
end
