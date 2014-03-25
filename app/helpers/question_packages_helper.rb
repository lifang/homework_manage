module QuestionPackagesHelper
  def load_type_class type
    case type
      when Question::TYPES[:LISTENING] then
          css_class =  "qType_write"
      when Question::TYPES[:READING] then
          css_class = "qType_read"
      when Question::TYPES[:TIME_LIMIT] then
          css_class = "qType_speed"
      when Question::TYPES[:SELECTING] then
          css_class =  "qType_choose"
      when Question::TYPES[:LINING] then
          css_class = "qType_ligature"
      when Question::TYPES[:CLOZE] then
          css_class = "qType_gap"
      when Question::TYPES[:SORT] then
          css_class = "qType_sort"
    end
    css_class
  end

  #判断该题包下是否已有十速挑战，有的话则返回数据
  def get_has_time_limit question_package_id
    teacher = Teacher.find_by_id(cookies[:teacher_id])
    user = User.find_by_id(teacher.user_id) if teacher && teacher.user_id
    @time_limit_user_name = user.name if user
    question = Question.find_by_types_and_question_package_id(Question::TYPES[:TIME_LIMIT],
      question_package_id)
    @time_limit_que_name = question.name if question
    @time_limit_que_time = question.created_at.strftime("%Y-%m-%d") if question && question.created_at
    @time_limit_branch_que = BranchQuestion.where(["question_id=?", question.id]) if question
    @time_limit_tags = BtagsBqueRelation.find_by_sql(["select bt.name, bbr.branch_question_id bq_id, bbr.branch_tag_id bt_id from
        btags_bque_relations bbr left join branch_tags bt on bbr.branch_tag_id=bt.id
        where bbr.branch_question_id in (?)", @time_limit_branch_que.map(&:id)]) if @time_limit_branch_que
  end
end
