#encoding: utf-8
class QuestionAdmin::QuestionManagesController < ApplicationController
  skip_before_filter :get_teacher_infos,:get_unread_messes
  before_filter :check_if_questionadmin, :only => [:index]
  
  def new
    @cells = Cell.where("teaching_material_id = ?",current_teacher.teaching_material_id ) if current_teacher
  end
end