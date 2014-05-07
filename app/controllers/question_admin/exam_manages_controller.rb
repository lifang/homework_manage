#encoding: utf-8
class QuestionAdmin::ExamManagesController < ApplicationController
  skip_before_filter :get_teacher_infos,:get_unread_messes
  before_filter :check_if_questionadmin, :only => [:index]
  layout 'question_admin/question_manages'
  def index
    @cells = Cell.where("teaching_material_id = ?",current_teacher.teaching_material_id ) if current_teacher
    @cell = Cell.find_by_id(params[:cell_id])
    @episode = Episode.find_by_id(params[:episode_id])
    @question_types = params[:question_types]
    if @cell
      @episodes = @cell.episodes
    end
    get_share_question
  end

  def delete_share_question
    share_question_id = params[:share_question_id]
    question = ShareQuestion.find_by_id(share_question_id)
    if question
      sbqs = question.share_branch_questions
      SbranchBranchTagRelation.delete_all(["share_branch_question_id in (?)", sbqs.map(&:id)]) if sbqs
      sbqs.each do |bq|
        bq.destroy
      end if sbqs
      question.destroy if question
      @status = 1
      @notice = '删除成功！'
    else
      @status=0
      @notice = '删除失败！'
    end
    get_share_question
    if @questions.length<1 && params[:page].to_i>1
      params[:page] = params[:page].to_i - 1
      get_share_question
    end
  end

  def edit_share_question
    share_question_id = params[:share_question_id]
    @b_tags = get_branch_tags(cookies[:teacher_id])
    teacher = Teacher.find_by_id cookies[:teacher_id]
    @user = teacher.user
    @question_pack = nil
    @question_package_id = 0
    @school_class_id = 0
    @questions = ShareQuestion.where(["id = ?", share_question_id])
    branch_questions = ShareBranchQuestion.where(["share_question_id = ?", @questions.map(&:id)])
    @branch_questions = branch_questions.group_by{|bq|bq.share_question_id}

    branch_tags = SbranchBranchTagRelation.find_by_sql(["select bt.name, bbr.id, bbr.share_branch_question_id, bbr.branch_tag_id,bq.share_question_id  from
        sbranch_branch_tag_relations bbr left join branch_tags bt on bbr.branch_tag_id=bt.id left join share_branch_questions bq
        on bq.id = bbr.share_branch_question_id where bbr.share_branch_question_id in (?) ", branch_questions.map(&:id)])

    h_branch_tags = branch_tags.group_by{|t|t.share_question_id}

    hash = {}
    h_branch_tags.each do |k, v|
      second_tags = v.group_by{|t|t.share_branch_question_id}
      hash[k] = second_tags
    end
    @branch_tags = hash
  end

  private
  def get_share_question
    episode_id = params[:episode_id].nil? || params[:episode_id].strip == "" ? "and 1=1 " : "and e.id=#{params[:episode_id]} "
    cell_id = params[:cell_id].nil? || params[:cell_id].strip == "" ? " and 1=1 " : " and c.id=#{params[:cell_id]} "
    question_types = params[:question_types].nil? || params[:question_types].strip == "" ? "and 1=1 " : "and sq.types=#{params[:question_types].to_i} "
    @questions = ShareQuestion.share_question_list current_user.id,cell_id,episode_id,question_types,params[:page] ||= 1
  end
end
