module StatisticsHelper
  #根据题型显示图片
  def questions_img_class question_types
    case question_types.to_i
      when Question::TYPES[:LISTENING]; then return "q_listen"
      when Question::TYPES[:READING]; then return "q_read"
      when Question::TYPES[:TIME_LIMIT]; then return "q_speed"
      when Question::TYPES[:SELECTING]; then return "q_choose"
      when Question::TYPES[:LINING]; then return "q_ligature"
      when Question::TYPES[:CLOZE]; then return "q_speed"
      when Question::TYPES[:SORT]; then return "q_speed"
    end
  end

  #根据正确率显示颜色
  def correct_rate_color correct_rate
    case correct_rate.to_i
      when 100 ; then return "color100"
      when (90..99) ; then return "color90"
      when (80..89) ; then return "color80"
      when (70..79) ; then return "color70"
      when (60..69) ; then return "color60"
      when (50..59) ; then return "color50"
      when (40..49) ; then return "color40"
      when (30..39) ; then return "color30"
      when (20..29) ; then return "color20"
      when (10..19) ; then return "color10"
      when (0..9) ; then return "color10"
      else return "color10"
    end
  end

  #计算每一答题的正确率
  def calculate_every_question_correct_rate branch_questions, types
    every_que_avg_correct_rate = 0
    correct_rate_arry = branch_questions.map {|bq| bq["ratio"] }
    correct_rates = []
    correct_rate_arry.each do |e|
      correct_rates << e.to_i if e.present?
    end
    every_que_avg_correct_rate = (eval correct_rates.join('+'))/correct_rates.length if correct_rates.present?
  end

  #根据学生的答题记录返回学生答错的小题id
  def read_answer_hash answer_hash, types
    wrongs_id = []
    p types
    if answer_hash.present?
      if answer_hash[Question::TYPE_NAME_ARR[types.to_i]].present? &&
              answer_hash[Question::TYPE_NAME_ARR[types.to_i]]["questions"].present?
        questions = answer_hash[Question::TYPE_NAME_ARR[types.to_i]]["questions"]
        p questions
        questions.each do |question|
          if question["branch_questions"].present?
            branch_questions = question["branch_questions"]
            branch_questions.each do |bq|
              if (bq["ratio"].to_i >= 0 && bq["ratio"].to_i < 100) && bq["id"].to_i > 0
                wrongs_id << bq["id"].to_i
              end
            end
          end
        end
      end
    end
    wrongs_id
  end
end
