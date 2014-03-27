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
