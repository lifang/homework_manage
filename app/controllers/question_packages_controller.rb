#encoding: utf-8
include QuestionPackagesHelper
class QuestionPackagesController < ApplicationController
  before_filter :sign?, :get_unread_messes
  before_filter :get_cells_and_episodes, :only => [:new, :render_new_question]
  before_filter :get_school_class
  def index
    respond_to do |f|
      #分享题目的分页
      f.js{
        @question_pack = QuestionPackage.find_by_id(params[:question_package_id])
        @question = Question.find_by_id(params[:question_id])
        @sort_name = params[:sort_name]
        sort = @sort_name == "up" ? "asc" : "desc"
        @share_questions = ShareQuestion.share_questions(@question.cell_id, @question.episode_id, @question.types, sort, params[:page])
        @href = "/question_packages?question_package_id=#{@question_pack.id}&question_id=#{@question.id}"
      }
      f.html
    end
  end
  
  def new
    @question_pack = QuestionPackage.create
    redirect_to "/school_classes/#{@school_class.id}/question_packages/#{@question_pack.id}/new_index"
  end
  def new_index
    @question_pack = QuestionPackage.find_by_id(params[:id])
    @question_type = Question::TYPES_NAME
    @cells = Cell.where("teaching_material_id = ?",@school_class.teaching_material_id )
    render 'new'
  end
  def setting_episodes
    @cells = Cell.find_by_id(params[:cell_id])
    @episodes = @cells.episodes
  end
  #show完形填空
  def show_wanxin

  end
  #新建题包其中第一个答题第三步之后，建题包，建答题
  def create
    question_type, new_or_refer, cell_id, episode_id, question_pack_id = params[:question_type].to_i, params[:new_or_refer], params[:cell_id], params[:episode_id], params[:question_pack_id]
    status = false
    @question_type = question_type
    QuestionPackage.transaction do
      if new_or_refer == "0"
        status = create_new_question_pack_and_ques(question_pack_id,cell_id,episode_id,question_type, status)
        if status
          render :partial => "questions/new_branch"
        else
          render :text => "-1"  #保存失败
        end
      else
        @share_questions = ShareQuestion.share_questions(cell_id, episode_id, question_type, "desc", 1)
        if @share_questions.present?
          status = create_new_question_pack_and_ques(question_pack_id,cell_id,episode_id,question_type, status)
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
  end

  def update
    question_package = QuestionPackage.find_by_id(params[:id])
    if question_package && params[:question_package][:name]
      question_package.update_attribute(:name, params[:question_package][:name])
    end
    #redirect_to school_class_question_package_questions_path(school_class_id, question_package)
    redirect_to school_class_homeworks_path()
  end

  def render_new_question
    @question_pack_id = params[:id] if params[:id].present? && params[:id] != 'undefined'
    render :partial => "three_step"
  end

  #预览作业
  def show
    @question_pack = QuestionPackage.find_by_id(params[:id])
    teacher = Teacher.find_by_id cookies[:teacher_id]
    @user = User.find_by_id teacher.user_id.to_i
    @origin_questions = nil
    question_type = QuestionPackage.get_one_package_questions @question_pack.id
    @question_type = question_type.map(&:types).uniq.sort if question_type.present? || []
    p @question_type
    ques = []
    question = Question
    .select("id, types, name, full_text, content, questions_time, created_at")
    .where(["questions.question_package_id = ?", @question_pack.id])
    question_id = question.map{|q| q.id }.uniq
    branch_questions = BranchQuestion
    .select("content, resource_url, options, answer, question_id, id")
    .where(["question_id in (?)", question_id])
    branch_questions_id = branch_questions.map{|bq| bq.id}
    branch_questions = branch_questions.group_by {|b| b.question_id}
    @branch_tags = BtagsBqueRelation.joins("left join branch_tags bt on btags_bque_relations.branch_tag_id = bt.id")
    .select("btags_bque_relations.branch_question_id, bt.id, bt.name")
    .where(["branch_question_id in (?) and bt.id is not null",branch_questions_id])
    .group_by {|t| t.branch_question_id}
    question.each do |q|
      branch_ques = []
      if branch_questions[q.id].present?
        branch_ques = branch_questions[q.id]
      end
      ques << {:id => q.id, :name => q.name, :types => q.types, :full_text => q.full_text,
        :questions_time => q.questions_time, :created_at => q.created_at,
        :content => q.content, :branch_questions => branch_ques}
    end
    @questions = ques.group_by {|q| q[:types]}
    p @questions
    #p @branch_tags
  end

  #删除作业
  def destroy
    question_pack = QuestionPackage.find_by_id(params[:id])
    QuestionPackage.transaction do
    
      #作业删除文件夹开始
      delete_question_package_folder(question_pack)
      #作业删除文件夹结束
      
      if question_pack.destroy
        flash[:notice] = "删除成功"
        redirect_to "/school_classes/#{school_class_id}/homeworks"
      end
    end
  end

  #新建十速挑战
  def new_time_limit
    @b_tags = get_branch_tags(cookies[:teacher_id])
    respond_to do |f|
      f.js
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

  def create_new_question_pack_and_ques(question_pack_id,cell_id,episode_id,question_type, status)
    if question_pack_id.present?
      @question_pack = QuestionPackage.find_by_id(question_pack_id)
    else
      @question_pack = QuestionPackage.create(:school_class_id => school_class_id)
    end
    if @question_pack
      @question = @question_pack.questions.create({:cell_id => cell_id, :episode_id => episode_id, :types => question_type})
    end
    status = @question_pack && @question
    status
  end


end