#encoding:utf-8
class ShareQuestionsController < ApplicationController
  #显示分享题库中的某一题及小题
  def view
    @question_pack = QuestionPackage.find_by_id params[:question_package_id].to_i
    @question = Question.find_by_id params[:question_id].to_i
    @share_question = ShareQuestion.find_by_id(params[:share_question_id].to_i)
    @branch_questions = @share_question.share_branch_questions
  end

  # 列出引用的题目
  def list_questions_by_type
    @school_class_id, @question_type, @cell_id, @episode_id, @question_pack_id = params[:school_class_id], params[:types].to_i,params[:cell_id], params[:episode_id], params[:question_pack_id]
    type_name = Question::TYPES_NAME[@question_type]
    @share_questions = ShareQuestion.share_questions(@cell_id, @episode_id, @question_type, "desc", 1)
    share_branch_questions = ShareBranchQuestion.where(:share_question_id => @share_questions.map(&:id))
    @share_branch_questions = share_branch_questions.group_by{|sbq| sbq.share_question_id}
    branch_question_ids = share_branch_questions.map(&:id)
    @branch_tags = BranchTag.find_by_sql(["select bt.*, bbr.branch_question_id from branch_tags bt left join btags_bque_relations bbr
    on bbr.branch_tag_id = bt.id left join branch_questions bq on bq.id = bbr.branch_question_id where bbr.branch_question_id in (?)",
        branch_question_ids]).group_by{|bt| bt.branch_question_id}
    if @share_questions.present?
      render :partial =>"questions/new_reference"
    else
      render :json =>{:msg => "该单元下的 <b>#{type_name}题</b> 没有题目可以引用", :status => "-2" }  #"该单元下没有题目可以引用"
    end
  end

end
