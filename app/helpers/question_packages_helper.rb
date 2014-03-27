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


  #第一次进去时,判断该题包下是否已有十速挑战，有的话则返回数据
  def new_get_has_time_limit question_package_id
    teacher = Teacher.find_by_id(cookies[:teacher_id])
    user = User.find_by_id(teacher.user_id) if teacher && teacher.user_id
    @time_limit_user_name = user.name if user
    question = Question.find_by_types_and_question_package_id(Question::TYPES[:TIME_LIMIT],
      question_package_id)
    @time_limit_que_id = question.id if question
    @tlqqt = trans_int_to_time(question.questions_time.to_i) if question && !question.questions_time.nil?
    @time_limit_que_name = question.name if question && question.name
    @time_limit_que_time = question.created_at.strftime("%Y-%m-%d") if question && question.created_at
    @time_limit_branch_que = BranchQuestion.where(["question_id=?", question.id]) if question
    @time_limit_tags = BtagsBqueRelation.find_by_sql(["select bt.name, bbr.branch_question_id bq_id, bbr.branch_tag_id bt_id from
        btags_bque_relations bbr left join branch_tags bt on bbr.branch_tag_id=bt.id
        where bbr.branch_question_id in (?)", @time_limit_branch_que.map(&:id)]) if @time_limit_branch_que
  end
  #判断该题包下是否已有十速挑战，有的话则返回数据
  def get_has_time_limit question_package_id
    teacher = Teacher.find_by_id(cookies[:teacher_id])
    user = User.find_by_id(teacher.user_id) if teacher && teacher.user_id
    @time_limit_user_name = user.name if user
    question = Question.find_by_types_and_question_package_id(Question::TYPES[:TIME_LIMIT],
      question_package_id)
    if request.url.include?("new_time_limit") && question.nil?
        question = Question.create(:types => Question::TYPES[:TIME_LIMIT], :question_package_id => question_package_id)
    end
    @time_limit_que_id = question.id if question
    @tlqqt = trans_int_to_time(question.questions_time.to_i) if question && !question.questions_time.nil?
    @time_limit_que_name = question.name if question && question.name
    @time_limit_que_time = question.created_at.strftime("%Y-%m-%d") if question && question.created_at
    @time_limit_branch_que = BranchQuestion.where(["question_id=?", question.id]) if question
    @time_limit_tags = BtagsBqueRelation.find_by_sql(["select bt.name, bbr.branch_question_id bq_id, bbr.branch_tag_id bt_id from
        btags_bque_relations bbr left join branch_tags bt on bbr.branch_tag_id=bt.id
        where bbr.branch_question_id in (?)", @time_limit_branch_que.map(&:id)]) if @time_limit_branch_que
    #        选择题
    question_select = Question.find_by_types_and_question_package_id(Question::TYPES[:SELECTING],question_package_id)
    @time_select_branch_que = BranchQuestion.where(["question_id=?", question_select.id]) if question_select
    @time_select_tags = BtagsBqueRelation.find_by_sql(["select bt.name, bbr.branch_question_id bq_id, bbr.branch_tag_id bt_id from
        btags_bque_relations bbr left join branch_tags bt on bbr.branch_tag_id=bt.id
        where bbr.branch_question_id in (?)", @time_select_branch_que.map(&:id)]) if @time_select_branch_que
    #连线题
    question_lianxian = Question.find_by_types_and_question_package_id(Question::TYPES[:LINING],question_package_id)
    @time_lianxian_branch_que = BranchQuestion.where(["question_id=?", question_lianxian.id]) if question_lianxian
    @time_lianxian_tags = BtagsBqueRelation.find_by_sql(["select bt.name, bbr.branch_question_id bq_id, bbr.branch_tag_id bt_id from
        btags_bque_relations bbr left join branch_tags bt on bbr.branch_tag_id=bt.id
        where bbr.branch_question_id in (?)", @time_lianxian_branch_que.map(&:id)]) if @time_lianxian_branch_que
  end

  #将int转换成时分秒
  def trans_int_to_time int
    hour = 0
    minute = 0
    second = 0
    if int > 0
      has_hour = int / 3600
      if has_hour >= 1
        hour = has_hour
      end
      int = int - (has_hour * 3600)
      has_minute = int / 60
      if has_minute >= 1
        minute = has_minute
      end
      int = int - (has_minute * 60)
      has_second = int
      if has_second >= 1
        second = has_second
      end
    end
    return [hour, minute, second]
  end

  #将时分秒转化为int
  def trans_time_to_int hour=nil, minute=nil, second=nil
    time = 0
    if hour
      time += hour.to_i * 3600
    end
    if minute
      time += minute.to_i * 60
    end
    if second
      time += second.to_i
    end
    return time
  end
end
