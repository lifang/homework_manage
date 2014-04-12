#encoding: utf-8
class QuestionAdmin::ExamManagesController < ApplicationController
  skip_before_filter :get_teacher_infos,:get_unread_messes
  before_filter :check_if_questionadmin, :only => [:index]
  layout 'question_admin/question_manages'
  def index
    @cells = Cell.where("teaching_material_id = ?",current_teacher.teaching_material_id ) if current_teacher
    #    @questions = ShareQuestion.find_by_sql("SELECT * from  share_questions sq where sq.user_id = #{current_user.id}")
    sql_question = 'SELECT sq.id,sq.name,sq.types,sq.created_at,c.name cell_name,e.name episode_name
                    from  share_questions sq INNER JOIN cells c on c.id=sq.cell_id
                    INNER JOIN episodes e on e.id=sq.episode_id where sq.user_id = ?'
    @questions = ShareQuestion.find_by_sql([sql_question,current_user.id])
  end

  #设置单元
  def set_cell
    @cells = Cell.find_by_id(params[:cell_id])
    @episodes = nil
    if @cells
      @episodes = @cells.episodes
    end
    #    unit_episode = params[:unit_episode].nil? || params[:unit_episode].strip == "" ? "" : params[:unit_episode]
    cell_id = params[:cell_id].nil? || params[:cell_id].strip == "" ? " and 1=1 " : " and c.id=#{params[:cell_id].to_i} "
    question_types = params[:question_types].nil? || params[:question_types].strip == "" ? "and 1=1 " : "and sq.types=#{params[:question_types].to_i} "
    episode_id = "and 1=1 "
    @questions = ShareQuestion.share_question_list current_user.id,cell_id,episode_id,question_types
  end

  #设置题型
  def set_episode
    episode_id = params[:episode_id].nil? || params[:episode_id].strip == "" ? "and 1=1 " : "and e.id=#{params[:episode_id]} "
    cell_id = params[:cell_id].nil? || params[:cell_id].strip == "" ? " and 1=1 " : " and c.id=#{params[:cell_id]} "
    question_types = params[:question_types].nil? || params[:question_types].strip == "" ? "and 1=1 " : "and sq.types=#{params[:question_types].to_i} "
    @questions = ShareQuestion.share_question_list current_user.id,cell_id,episode_id,question_types
  end

  #设置题型
  def set_question_type
    episode_id = params[:episode_id].nil? || params[:episode_id].strip == "" ? "and 1=1 " : "and e.id=#{params[:episode_id]} "
    cell_id = params[:cell_id].nil? || params[:cell_id].strip == "" ? " and 1=1 " : " and c.id=#{params[:cell_id]} "
    question_types = params[:question_types].nil? || params[:question_types].strip == "" ? "and 1=1 " : "and sq.types=#{params[:question_types].to_i} "
    @questions = ShareQuestion.share_question_list current_user.id,cell_id,episode_id,question_types
  end
end
