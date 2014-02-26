#encoding: utf-8
class QuestionsController < ApplicationController
  before_filter :sign?

  def index
    @question_pack = QuestionPackage.find_by_id(params[:question_package_id])
    @questions = @question_pack.questions
    @question = @questions[0]
    @branch_questions = BranchQuestion.where(:question_id => @question.try(:id)) if @question.present?
    if @question.present?
      render :edit
    else
      flash[:notice] = "作业里面没有题目，重新创建或者删除作业"
      redirect_to "/school_classes/#{school_class_id}/question_packages/new"
    end
    
  end
  
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
      flash[:notice]="删除成功"
      redirect_to school_class_question_package_questions_path(school_class_id, question_pack)
    end
  end

  #分享题目
  def share
    question = Question.find_by_id(params[:id])
    question_pack = question.question_package
    Question.transaction do
      unless question.if_shared
        branch_questions = question.branch_questions
        if branch_questions.present?
          share_question = ShareQuestion.create({:user_id => current_user.id, :name => question.name, :types => question.types, :cell_id => question.cell_id, :episode_id => question.episode_id})
          if share_question
            question.branch_questions.each do |bq|
              new_resource_url = copy_file(share_media_path, question_pack, bq, bq.resource_url) #分享的时候，拷贝音频
              share_question.share_branch_questions.create({:content => bq.content, :resource_url => new_resource_url})
            end
          end
          question.update_attribute(:if_shared, true)
          @status = 0 #分享成功
        else
          @status = 2 #大题下面无小题，提示
        end
      else
        @status = 1 #已经分享过
      end
    end
  end

  #预览题目
  def show
    @question = Question.find_by_id(params[:id])
    @question_pack = QuestionPackage.find_by_id(params[:question_package_id])
    @branch_questions = @question.branch_questions
    respond_to do |f|
      f.js{}
      f.html
    end
  end

  #引用题目
  def reference
    @question_pack = QuestionPackage.find_by_id(params[:question_package_id])
    @questions = @question_pack.questions
  
    @question = Question.find_by_id(params[:question_id])
    @branch_questions = @question.branch_questions
    share_question = ShareQuestion.find_by_id(params[:id])
    share_branch_questions = share_question.share_branch_questions
    Question.transaction do
      share_branch_questions.each do |sbq|
        branch_question = @question.branch_questions.create({:content => sbq.content})
        new_resource_url = copy_file(media_path, @question_pack, branch_question, sbq.resource_url) #引用的时候，拷贝音频
        branch_question.update_attribute(:resource_url, new_resource_url)
        if branch_question == @question.branch_questions.first
          @question.update_attribute(:name, branch_question.content.length > 38 ? branch_question.content[0..35] + "..." : branch_question.content)
        end
      end
    end
  end

  private

  #引用的时候，拷贝音频
  def copy_file(media_path_url, question_pack, branch_question, source_resource_url)
    full_media_path = "/public" + media_path_url % question_pack.id
    question_pack_folder = Rails.root.to_s + full_media_path
    original_resource_url = Rails.root.to_s + "/public" + source_resource_url
    FileUtils.mkdir_p(question_pack_folder) unless Dir.exists?(question_pack_folder)
    file_extension = File.extname(original_resource_url)
    filename = "media_%d" % branch_question.id + file_extension
    FileUtils.cp original_resource_url, (question_pack_folder + filename)
    new_audio_path = media_path_url % question_pack.id + filename
    return new_audio_path
  end
end