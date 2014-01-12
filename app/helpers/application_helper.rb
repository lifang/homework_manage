module ApplicationHelper
  #重建xml结构,转换成哈希后去掉冗余键
  def restruct_xml xml_string
    begin
      student_answers_xml = Hash.from_xml(xml_string)
    rescue
      questions_collections = nil
    end
    #lisentings = nil
    #readings = nil
    #p student_answer_record
    if student_answers_xml["questions"].present?
      questions = student_answers_xml["questions"]
      if questions["listening"]["question"].present?
        lisenting_questions = questions["listening"]["question"]  #听力题
        #如果听力或朗读题只有一题,则将该题目的哈希转换为数组
        if lisenting_questions.class == Hash  #如果听力题中的题目只有一题,将哈希转为数组
          tmp = lisenting_questions
          lisenting_questions = []
          lisenting_questions << tmp
          #重组哈希,去掉question键和branch_question键
          lisentings = []
          lisenting_questions.each do |question|
            branch_questions = []
            if question["branch_questions"].class == Hash
              branch_questions << question["branch_questions"]["branch_question"]
            else
              question["branch_questions"].each do |e|
                branch_questions << e["branch_question"]
              end
            end
            lisentings << {"id" => question["id"], "branch_questions" => branch_questions}
          end
        elsif questions["listening"].present?
          lisentings = questions["listening"]
        end
      end

      if questions["reading"]["question"]
        reading_questions = questions["reading"]["question"]  #朗读题
        #如果听力或朗读题只有一题,则将该题目的哈希转换为数组
        if reading_questions.class == Hash  #如果阅读题中的题目只有一题,将哈希转为数组
          tmp = reading_questions
          reading_questions = []
          reading_questions << tmp
        end
        #重组哈希,去掉question键和branch_question键
        readings = []
        reading_questions.each do |question|
          branch_questions = []
          if question["branch_questions"].class == Hash
            branch_questions << question["branch_questions"]["branch_question"]
          else
            question["branch_questions"].each do |e|
              branch_questions << e["branch_question"]
            end
          end
          readings << {"id" => question["id"], "branch_questions" => branch_questions}
        end
      elsif questions["reading"].present?
        readings = questions["reading"]
      end
      questions_collections = {"listening"=> lisentings,"reading" => readings}
    else
      questions_collections = nil
    end
    questions_collections
  end
end
