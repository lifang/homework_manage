module QuestionPackagesHelper
  def load_type_class type
    case @question[0][:types]
     when Question::TYPES[:LISTENING] then "qType_write"
     when Question::TYPES[:READING] then "qType_read"
     when Question::TYPES[:TIME_LIMIT] then "qType_speed"
     when Question::TYPES[:SELECTING] then "qType_choose"
     when Question::TYPES[:LINING] then "qType_ligature"
     when Question::TYPES[:CLOZE] then "qType_gap"
     when Question::TYPES[:SORT] then "qType_sort"
    end
  end
end
