#encoding: utf-8
class QuestionPackagesController < ApplicationController
  before_filter :sign?
  before_filter :get_cells_and_episodes, :only => [:new, :render_new_question]

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
    @question_pack = QuestionPackage.new
  end

  #新建题包其中第一个答题第三步之后，建题包，建答题
  def create
    question_type, new_or_refer, cell_id, episode_id, question_pack_id = params[:question_type].to_i, params[:new_or_refer], params[:cell_id], params[:episode_id], params[:question_pack_id]
    status = false
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
    p @question_pack
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
    
      #作业删除文件夹开始
      delete_question_package_folder(question_pack)
      #作业删除文件夹结束
      
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