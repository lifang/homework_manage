class BranchQuestionsController < ApplicationController

  def create
    @question_pack = QuestionPackage.find_by_id(params[:question_package_id])
    @question = Question.find_by_id(params[:question_id])
    @tr_index = params[:tr_index].to_i
    BranchQuestion.transaction do
      @branch_question = @question.branch_questions.create(params[:branch])
      if @branch_question
        if @branch_question == @question.branch_questions.first
          @question.update_attribute(:name, @branch_question.content.length > 38 ? @branch_question.content[0..35] + "..." : @branch_question.content)
        end
        resource_url_path = save_into_folder(@question_pack, @branch_question, params[:branch_url])
        @branch_question.update_attributes({:resource_url => resource_url_path} ) if resource_url_path
        @action_name = "create"
        render :success
      else
        render :failed
      end
    end
  end

  def update
    @question_pack = QuestionPackage.find_by_id(params[:question_package_id])
    @question = Question.find_by_id(params[:question_id])
    branch_question = BranchQuestion.find_by_id(params[:id])
    branch_question =branch_question.update_attribute(:content, params[:branch][:content])
    if branch_question
      @action_name = "update"
      render :success
    else
      render :failed
    end
  end

  def destroy
    @question_pack = QuestionPackage.find_by_id(params[:question_package_id])
    @question = Question.find_by_id(params[:question_id])
    @branch_question = BranchQuestion.find_by_id(params[:id])
    if @branch_question.destroy
      resource_path = (Rails.root.to_s + "/public" + @branch_question.resource_url)
      File.delete resource_path if File.exists?(resource_path)
      @status = 0
    else
      @status = 1
    end
    respond_to do |f|
      f.html{ render :text=> 0}
      f.js
    end
  end
end