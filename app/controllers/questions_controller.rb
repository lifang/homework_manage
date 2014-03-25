#encoding: utf-8
class QuestionsController < ApplicationController
  before_filter :sign?, :get_unread_messes

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


  #显示当前题包下的题目
  def question_selects_all
    types = params[:types]
    question_package_id =  params[:question_package_id]
    @questions = Question.where("question_package_id=#{question_package_id}").where("types=#{types}")
  end
  def show_branch_question
    question_id = params[:question_id]
    types = params[:types]
    @branch_question = BranchQuestion.where("question_id=#{question_id}").where("types=#{types}")
    if @branch_question
      render :json =>{:status=>1}
    else
      render :json => {:status=>0}
    end
  end
  #  显示选择
  def show_select
    cell_id = params[:select1]
    episode_id = params[:select2]
    types = params[:types]
    @question_package_id = params[:question_package_id]
    @questions = Question.where("question_package_id=#{@question_package_id}").where("types=#{types}")
    @question = Question.create(:cell_id=>cell_id,:episode_id=>episode_id,:question_package_id=>@question_package_id,:types=>Question::TYPES[:SELECTING])
  end
  #保存选择题
  def save_select
    @index_new = params[:index_new]
    @question_id = params[:question_id]
    @question = Question.find_by_id @question_id
    select_content = params[:select_content]
    check_select = params[:check_select]
    select_value1 = params[:select_value1]
    select_value2 = params[:select_value2]
    select_value3 = params[:select_value3]
    select_value4 = params[:select_value4]
    info =  Question.sava_select_qu check_select,select_value1,select_value2,select_value3,select_value4
    answer = info[:answer]
    options = info[:options]
    @branch_question = BranchQuestion.create(:content=>select_content,:types=>Question::TYPES[:SELECTING],:question_id=>@question_id,
      :options=>options,:answer=> answer)
    @question_package_id = params[:question_package_id]
    #    @questions = Question.find_by_question_package_id @question_package_id
  end

  #更新选择题
  def update_select
    @index_new = params[:index_new]
    @question_id = params[:question_id]
    @question = Question.find_by_id @question_id
    select_content = params[:select_content]
    check_select = params[:check_select]
    select_value1 = params[:select_value1]
    select_value2 = params[:select_value2]
    select_value3 = params[:select_value3]
    select_value4 = params[:select_value4]
    info =  Question.sava_select_qu check_select,select_value1,select_value2,select_value3,select_value4
    answer = info[:answer]
    options = info[:options]
    branch_question_id = params[:branch_question_id]
    branchquestion = BranchQuestion.find_by_id branch_question_id
    if branchquestion
      branchquestion.update_attributes(:content=>select_content,:types=>Question::TYPES[:SELECTING],:question_id=>@question_id,
        :options=>options,:answer=> answer)
      @status = 1
    else
      @status = 0
    end
  end


  #创建连线题连线
  def new_lianxian
    cell_id = params[:select1]
    episode_id = params[:select2]
    types = params[:types]
    @question_package_id = params[:question_package_id]
    @questions = Question.where("question_package_id=#{@question_package_id}").where("types=#{types}")
    @question = Question.create(:cell_id=>cell_id,:episode_id=>episode_id,:question_package_id=>@question_package_id,:types=>Question::TYPES[:LINING])
  end
  #  保存连线题
  def save_lianxian
    @index_new = params[:index_new]
    content_index = params[:content_index]
    @content_index = content_index.to_i+1
    left_lianxian = params[:left_lianxian]
    right_lianxian = params[:right_lianxian]
    question_id = params[:question_id]
    @question = Question.find_by_id question_id
    options = left_lianxian + ';||;' + right_lianxian
    @branch_question = BranchQuestion.create(:content=>content_index,:types=>Question::TYPES[:LINING],:question_id=>question_id,
      :options=>options,:answer=> options)
    @question_package_id = params[:question_package_id]
  end


  #更新连线题
  def update_lianxian
    @index_new = params[:index_new]
    content_index = params[:content_index]
    @content_index = content_index.to_i+1
    left_lianxian = params[:left_lianxian]
    right_lianxian = params[:right_lianxian]
    question_id = params[:question_id]
    @question = Question.find_by_id question_id
    options = left_lianxian + ';||;' + right_lianxian
    branch_question_id = params[:branch_question_id]
    branchquestion = BranchQuestion.find_by_id branch_question_id
    if branchquestion
      branchquestion.update_attributes(:content=>content_index,:types=>Question::TYPES[:LINING],:question_id=>question_id,
        :options=>options,:answer=> options)
      @status = 1
    else
      @status = 0
    end
  end

  #删除小题
  def delete_branch_question
    @branch_question_id = params[:id]
    branch_question = BranchQuestion.find_by_id(@branch_question_id)
    if branch_question && branch_question.destroy
      @status = 1
    else
      @status = 0
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
          if bq.resource_url.present?
            resource_path = (Rails.root.to_s + "/public" + bq.resource_url)
            File.delete resource_path if File.exists?(resource_path)
          end
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
              new_resource_url = copy_file(SAHRE_MEDIA_PATH, question_pack, bq, bq.resource_url) if bq.resource_url.present? #分享的时候，拷贝音频
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
        new_resource_url = copy_file(MEDIA_PATH, @question_pack, branch_question, sbq.resource_url) if sbq.resource_url.present? #引用的时候，拷贝音频
        branch_question.update_attribute(:resource_url, new_resource_url)
        if branch_question == @question.branch_questions.first
          @question.update_attribute(:name, branch_question.content.length > 38 ? branch_question.content[0..35] + "..." : branch_question.content)
        end
      end
    end
  end

  private

  #分享或者引用的时候，拷贝音频
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