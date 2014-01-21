#encoding: utf-8
class QuestionsController < ApplicationController

  def index
    @question_pack = QuestionPackage.find_by_id(params[:question_package_id])
    @questions = @question_pack.questions
    @question = @questions[0]
    @branch_questions = BranchQuestion.where(:question_id => @question.try(:id)) if @question.present?
    render :edit
  end

  #第四步，保存新建的一个大题
=begin
  def update
    @question_pack = QuestionPackage.find_by_id(params[:question_package_id])
    @question = Question.find_by_id(params[:id])
    content_arr = params[:branch_content]
    resource_url_arr = params[:branch_url]
    
    flag = true
    BranchQuestion.transaction do
      content_arr.each_with_index do |content, index|
        bq = @question.branch_questions.create(:content => content)
        resource_url_path = save_into_folder(@question_pack, bq, resource_url_arr[index])if resource_url_arr[index]
        bq.update_attributes({:resource_url => resource_url_path} ) if resource_url_path
        flag = false unless bq
      end
      if flag
        @edit_path = edit_question_package_question_path(@question_pack, @question)
        render :success
      else
        render :failed
      end
    end
  end
=end
  
  #编辑大题
  def edit
    @question_pack = QuestionPackage.find_by_id(params[:question_package_id])
    @question = Question.find_by_id(params[:id])
    @questions = @question_pack.questions
    @branch_questions = @question.branch_questions
    respond_to do |f|
      f.js
      f.html
    end
  end

  #删除大题
  def destroy
    question_pack = QuestionPackage.find_by_id(params[:question_package_id])
    question = Question.find_by_id(params[:id])
    branch_questions = question.branch_questions
    Question.transaction do
      if question.destroy
        branch_questions.each do |bq|
          resource_path = (Rails.root.to_s + "/public" + bq.resource_url)
          File.delete resource_path if File.exists?(resource_path)
        end
      end
    end
    redirect_to question_package_questions_path(question_pack)
  end

  #分享题目
  def share
    question = Question.find_by_id(params[:id])
    Question.transaction do
      unless question.if_shared
        share_question = ShareQuestion.create({:user_id => current_user.id, :name => question.name})
        if share_question
          question.branch_questions.each do |bq|
            share_question.share_branch_questions.create({:content => bq.content, :resource_url => bq.resource_url})
          end
        end
        question.update_attribute(:if_shared, true)
        @status = 0
      else
        @status = 1
      end
    end
  end

  #预览题目
  def show
    
  end

  #引用题目
  def reference
    question = Question.find_by_id(params[:question_id])
    share_question = ShareQuestion.find_by_id(params[:id])
    share_branch_questions = share_question.share_branch_questions
    Question.transaction do
      share_branch_questions.each do |sbq|
        question.branch_questions.create({:content => sbq.content, :resource_url => sbq.resource_url})
      end
    end
  end

end