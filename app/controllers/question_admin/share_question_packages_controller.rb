#encoding: utf-8
class QuestionAdmin::ShareQuestionPackagesController < ApplicationController
  skip_before_filter :get_teacher_infos,:get_unread_messes
  before_filter :check_if_questionadmin, :only => [:index]
  layout "/question_admin/question_manages"
  
  def index
    @share_question_packages = current_teacher.share_question_packages
  end

  def new
    @share_question_package = current_teacher.share_question_packages.create
    redirect_to "/question_admin/share_question_packages/#{@share_question_package.id}/edit"
  end

  def edit
    @school_class_id = -1
    @share_question_package = ShareQuestionPackage.find_by_id params[:id]
    @questions = @share_question_package.share_questions
    share_branch_questions = ShareBranchQuestion.where(["share_question_id in (?)", @questions.map(&:id)])
    @branch_questions = share_branch_questions.group_by{|bq|bq.share_question_id}

    #tags
    branch_tags = ShareBranchQuestion.bunch_branch_tags(share_branch_questions.map(&:id))
    h_branch_tags = branch_tags.group_by{|t|t.share_question_id} #{bqid
    hash = {}
    h_branch_tags.each do |k, v|
      second_tags = v.group_by{|t|t.share_branch_question_id}
      hash[k] = second_tags
    end
    @branch_tags = hash
    
    if @share_question_package.cell_id.present?
      @cell_id = @share_question_package.cell_id
      @cell_name = @share_question_package.cell.name
    end
    if @share_question_package.episode_id.present?
      @episode_id = @share_question_package.episode_id
      @episode_name = @share_question_package.episode.name
    end
    @b_tags = get_branch_tags(cookies[:teacher_id])
    @cells = Cell.where("teaching_material_id = ?",current_teacher.teaching_material_id )
  end
end