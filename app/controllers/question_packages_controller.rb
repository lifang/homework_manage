#encoding: utf-8
class QuestionPackagesController < ApplicationController
  before_filter :sign?
  before_filter :get_cells_and_episodes, :only => [:new, :render_new_question]
  require 'will_paginate/array'

  def index
    respond_to do |f|
      #分享题目的分页
      f.js{
        @question_pack = QuestionPackage.find_by_id(params[:question_package_id])
        @question = Question.find_by_id(params[:question_id])
        @sort_name = params[:sort_name]
        sort = @sort_name == "up" ? "asc" : "desc"
        @share_questions = ShareQuestion.find_by_sql("select u.name user_name, sq.* from share_questions sq inner join users u on sq.user_id = u.id where sq.types=#{@question.types} order by created_at #{sort}").paginate(:page => params[:page], :per_page => 8)
        @href = "/question_packages?question_package_id=#{@question_pack.id}&question_id=#{@question.id}"
      }
      f.html
    end
  end
  
  def new
    @question_pack = QuestionPackage.new
  end

  #新建题包其中第一个答题第三步之后，建题包，建答题
  def create
    question_type, new_or_refer, cell_id, episode_id, question_pack_id = params[:question_type], params[:new_or_refer], params[:cell_id], params[:episode_id], params[:question_pack_id]
    status = 0
    QuestionPackage.transaction do
      if question_pack_id.present?
        @question_pack = QuestionPackage.find_by_id(question_pack_id)
      else
        @question_pack = QuestionPackage.create(:school_class_id => school_class_id)
      end
      if @question_pack
        @question = @question_pack.questions.create({:cell_id => cell_id, :episode_id => episode_id, :types => question_type.to_i})
      else
        status =  1
      end
    
      if status ==0
        if new_or_refer == "0"
          render :partial => "questions/new_branch"
        else
          @share_questions = ShareQuestion.find_by_sql("select u.name user_name, sq.* from share_questions sq inner join users u on sq.user_id = u.id where sq.types=#{question_type.to_i} order by created_at desc").paginate(:page => params[:page], :per_page => 8)
          render :partial =>"questions/new_reference"
        end
      else
        render :text => "error"
      end
    end
  end

  def update
    question_package = QuestionPackage.find_by_id(params[:id])
    if question_package && params[:question_package][:name]
      question_package.update_attribute(:name, params[:question_package][:name])
    end
    redirect_to question_package_questions_path(question_package)
  end

  def render_new_question
    @question_pack_id = params[:id] if params[:id].present? && params[:id] != 'undefined'
    render :partial => "three_step"
  end

  #预览作业
  def show
    @question_pack = QuestionPackage.find_by_id(params[:id])
    if params[:type].present?
      @questions = params[:type] == "listen" ? @question_pack.questions.listening : @question_pack.questions.reading
    else
      @questions = @question_pack.questions
    end
    @question = @questions[0]
    @branch_questions = BranchQuestion.where(:question_id => @question.try(:id)) if @question.present?
  end

  #删除作业
  def destroy
    question_pack = QuestionPackage.find_by_id(params[:id])
    QuestionPackage.transaction do
    
      random_branch_question = nil
      question_pack.questions.each do |question|
        if question.branch_questions.any?
          random_branch_question = question.branch_questions[0]  #找到某个小题的resource_url
          break
        end
      end
      
      #删除作业文件夹
      if random_branch_question.present?
        branch_question_resource_path = "#{Rails.root}/public/" + random_branch_question.resource_url
        question_pack_dir = File.dirname(branch_question_resource_path)
        FileUtils.remove_dir question_pack_dir if Dir.exist? question_pack_dir
      end
      
      if question_pack.destroy
        flash[:notice] = "删除成功"
        redirect_to "/school_classes/#{school_class_id}/homeworks"
      end
    end
  end

  private
  #获取单元以及对于的课程
  def get_cells_and_episodes
    school_class = SchoolClass.find_by_id(school_class_id) if school_class_id
    teaching_material = school_class.teaching_material if school_class
    @cells = teaching_material.cells if teaching_material
    @episodes = Episode.where(:cell_id => @cells.map(&:id)).group_by{|e| e.cell_id} if @cells
  end
  
end