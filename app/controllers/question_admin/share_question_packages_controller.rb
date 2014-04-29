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
    @b_tags = get_branch_tags(cookies[:teacher_id])
    @cells = Cell.where("teaching_material_id = ?",current_teacher.teaching_material_id )
  end

  def edit

  end
end