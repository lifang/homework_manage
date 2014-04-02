#encoding: utf-8
require 'fileutils'
require "mini_magick"
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

  def select_upload
    question_package_id = params[:question_package_id]
    type = params[:type]
    file_upload =  params[:select_file]
    if file_upload.size > 1048576
      text = "imgbig"
    else
      filename = file_upload.original_filename
      fileext = File.basename(filename).split(".")[1]
      resourse_url = "#{Rails.root}/public#{media_path % question_package_id}"
      FileUtils.mkdir_p "#{File.expand_path(resourse_url)}" if !(File.exist?("#{resourse_url}"))
      time_path = Time.now.strftime("%Y%m%dT%H%M%S")+"."+fileext
      url = resourse_url+time_path
      File.open(url, "wb")  {|f| f.write(file_upload.read) }
      #    img = MiniMagick::Image.read(file_upload)
      #    img.write "#{url}"
      url_img ="#{media_path % question_package_id}#{time_path}"
      if type=="voice"
        text = "voice;||;#{url_img}"
      else
        text = "photo;||;#{url_img}"
      end
    end
    render :text => text
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
    cell_id = params[:cell_id]
    episode_id = params[:episode_id]
    types = params[:types]
    @question_package_id = params[:question_package_id]
    @questions = Question.where("question_package_id=#{@question_package_id}").where("types=#{types}")
    @question = Question.create(:cell_id=>cell_id,:episode_id=>episode_id,:question_package_id=>@question_package_id,:types=>Question::TYPES[:SELECTING])
  end
  #保存选择题
  def save_select
    @resourse = params[:select_resourse]
    select_resourse = params[:select_resourse].nil? ? "" : params[:select_resourse]
    if select_resourse.present?
      resourse = "<file>" + select_resourse  + "</file>"
    else
      resourse = select_resourse
    end
    content_select = params[:select_content].nil? ? "" : params[:select_content]
    select_content = resourse + content_select
    @index_new = params[:index_new]
    @question_id = params[:question_id]
    @question = Question.find_by_id @question_id
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
    @question_pack = QuestionPackage.find_by_id @question_package_id
    #    @questions = Question.find_by_question_package_id @question_package_id
  end

  #更新选择题
  def update_select
    select_resourse = params[:select_resourse].nil? ? "" : params[:select_resourse]
    if select_resourse.present?
      resourse = "<file>" + select_resourse  + "</file>"
    else
      resourse = select_resourse
    end
    content_select = params[:select_content].nil? ? "" : params[:select_content]
    select_content = resourse + content_select
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
    p branch_question_id
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
    cell_id = params[:cell_id]
    episode_id = params[:episode_id]
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
    @question_pack = QuestionPackage.find_by_id @question_package_id
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
    
    if branch_question && branch_question.content &&  branch_question.content.include?("<file>")&& branch_question.content.include?("</file>")
      sourse = branch_question.content.scan(/(?<=\<file\>).*(?=\<[^\\]file\>)/)[0]
      sourse_all = "#{Rails.root}/public#{sourse}"
    end
    if branch_question && branch_question.destroy
      File.delete "#{sourse_all}" if File.exist?("#{sourse_all}")
      @status = 1
    else
      @status = 0
    end
    @status
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

  #引用大题题目
  def reference
    @question_pack = QuestionPackage.find_by_id(params[:question_package_id])
    share_question = ShareQuestion.find_by_id(params[:id])
    @question = @question_pack.questions.create({:cell_id => share_question.cell_id, :episode_id => share_question.episode_id,
        :types => share_question.types, :name => share_question.name, :questions_time => share_question.questions_time,
        :full_text => share_question.full_text })
    share_branch_questions = share_question.share_branch_questions
    Question.transaction do
      begin
        share_question.update_attribute(:referenced_count, share_question.referenced_count.to_i + 1)
        share_branch_questions.each do |sbq|
          branch_question = @question.branch_questions.create({:content => sbq.content, :options => sbq.options, :answer => sbq.answer, :types => sbq.types})
          new_resource_url = copy_file(media_path, @question_pack, branch_question, sbq.resource_url) if sbq.resource_url.present? #引用的时候，拷贝音频
          branch_question.update_attribute(:resource_url, new_resource_url) if new_resource_url
          sbq.branch_tags.each do |bt|
            branch_question.branch_tags << bt
          end
        end
        @status = 0
        @redirect_url = new_index_school_class_question_package_path(params[:school_class_id], params[:question_package_id])
      rescue Exception => e
        @status = 1
      end
    end
  end

end