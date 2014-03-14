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
    end
  end
end
