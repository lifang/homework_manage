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
end
