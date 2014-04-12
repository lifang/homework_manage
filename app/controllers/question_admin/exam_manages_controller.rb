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
    episode_id = params[:episode_id].nil? || params[:episode_id].strip == "" ? "and 1=1 " : "and e.id=#{params[:episode_id]} "
    cell_id = params[:cell_id].nil? || params[:cell_id].strip == "" ? " and 1=1 " : " and c.id=#{params[:cell_id]} "
    question_types = params[:question_types].nil? || params[:question_types].strip == "" ? "and 1=1 " : "and sq.types=#{params[:question_types].to_i} "
    @questions = ShareQuestion.share_question_list current_user.id,cell_id,episode_id,question_types
  end

  def edit_share_question
    share_question_id = params[:share_question_id]
    @b_tags = get_branch_tags(cookies[:teacher_id])
    teacher = Teacher.find_by_id cookies[:teacher_id]
    @user = teacher.user
    @question_pack = nil
    p share_question_id
    @questions = ShareQuestion.where(["id = ?", share_question_id])
    p @questions
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
    #    ques = []
    #    question = ShareQuestion
    #    .select("id, types, name, full_text, content, questions_time, created_at, cell_id, episode_id")
    #    .where(["id = ?", share_question_id])
    #
    #    branch_questions = ShareBranchQuestion
    #    .select("content, resource_url, options, answer, share_question_id, id")
    #    .where(["share_question_id = ?", share_question_id])
    #    branch_questions_id = branch_questions.map{|bq| bq.id}
    #    branch_questions = branch_questions.group_by {|b| b.question_id}
    #
    #    @branch_tags = SbranchBranchTagRelation.joins("left join branch_tags bt on sbranch_branch_tag_relations.branch_tag_id = bt.id")
    #    .select("sbranch_branch_tag_relations.share_branch_question_id, bt.id, bt.name")
    #    .where(["share_branch_question_id in (?) and bt.id is not null",branch_questions_id])
    #    .group_by {|t| t.share_branch_question_id}
    #
    #
    #    question.each do |q|
    #      branch_ques = []
    #      if branch_questions[q.id].present?
    #        branch_ques = branch_questions[q.id]
    #      end
    #      ques << {:id => q.id, :name => q.name, :types => q.types, :full_text => q.full_text,
    #        :questions_time => q.questions_time, :created_at => q.created_at, :cell_id => q.cell_id,
    #        :episode_id => q.episode_id, :content => q.content, :branch_questions => branch_ques}
    #    end
    #    @questions = ques
  end
end
