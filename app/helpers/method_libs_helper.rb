module MethodLibsHelper
  require 'rexml/document'
  require 'rexml/element'
  require 'rexml/parent'
  include REXML
  #读写xml答题记录
  def write_xml xml_file, question_id, branch_question_id, answer, types
    #question_types 0:listening  1:reading
    p xml_file
    types = types.to_i
    p !File.exist?(xml_file)
    if !File.exist? xml_file #如果文件不存在，则创建文件
      doc = REXML::Document.new
      questions = doc.add_element('questions')
      if types == 0 || types == 1
        if types == 0
          questions_types = questions.add_element('listening')
        elsif types == 1
          questions_types = questions.add_element('reading')
        end
        question = questions_types.add_element('question')
        q_id = question.add_element("id")
        branch_questions = question.add_element("branch_questions")
        branch_question = branch_questions.add_element("branch_question")
        b_id = branch_question.add_element("id")
        b_answer = branch_question.add_element("answer")
        q_id.add_text(question_id.to_s)
        b_id.add_text(branch_question_id.to_s)
        b_answer.add_text(answer.to_s)

        out = ""
        doc.write(out)
        p out
        File.open(xml_file,"w") do |f|
          f.write(out)
        end
      else
        File.delete(xml_file)
      end
    else  #如果文件存在，则直接读取文件

      xml_str = ""
      File.open(xml_file) do |file|
        file.each do |line|
          xml_str += line.to_s
        end
      end
      doc = REXML::Document.new xml_str
      if doc.root.has_elements? #如果根元素下有子元素则进行下一步处理
        #root.each do |e|
        #p e
        #end
        have_listening = !doc.root.elements["listening"].nil?
        have_reading = !doc.root.elements["reading"].nil?
        #0:listening  1:reading
        if have_listening == true && have_reading == false
          #p	doc.root.elements["listening"]
          #p	doc.root.elements["reading"]
          if types == 0
            count_q = 0 #计数大题
            count_b = 0 #计数小题
            doc.root.elements["listening"].each {|e|
              if e.class == REXML::Element && e.elements["id"].get_text.value.to_i == question_id
                count_q = 1
                e.elements["branch_questions"].each {|s|
                  if s.class == REXML::Element && s.elements["id"].get_text.value.to_i == branch_question_id
                    count_b = 1
                    p s.elements["id"].get_text.value.to_i
                    tmp = s.elements["answer"].get_text.value
                    p tmp
                    s.elements["answer"].remove()
                    anser = s.add_element("answer")
                    s = tmp.to_s + ";||;" + answer
                    anser.add_text(s)
                  end
                }
                if count_q == 1 && count_b == 0
                  branch_question = e.elements["branch_questions"].add_element("branch_question")
                  b_id = branch_question.add_element("id")
                  b_answer = branch_question.add_element("answer")
                  b_id.add_text(branch_question_id.to_s)
                  b_answer.add_text(answer.to_s)
                end
              end
            }
            if count_q == 0
              questions_types = doc.root.elements["listening"]
              question = questions_types.add_element('question')
              q_id = question.add_element("id")
              branch_questions = question.add_element("branch_questions")
              branch_question = branch_questions.add_element("branch_question")
              b_id = branch_question.add_element("id")
              b_answer = branch_question.add_element("answer")
              q_id.add_text(question_id.to_s)
              b_id.add_text(branch_question_id.to_s)
              b_answer.add_text(answer.to_s)
            end
          elsif types == 1
            questions_types = doc.root.add_element('reading')
            question = questions_types.add_element('question')
            q_id = question.add_element("id")
            branch_questions = question.add_element("branch_questions")
            branch_question = branch_questions.add_element("branch_question")
            b_id = branch_question.add_element("id")
            b_answer = branch_question.add_element("answer")
            q_id.add_text(question_id.to_s)
            b_id.add_text(branch_question_id.to_s)
            b_answer.add_text(answer.to_s)
          end
        elsif have_listening == false && have_reading == true
          #p	doc.root.elements["listening"]
          #p 	doc.root.elements["reading"]
          if types == 0
            questions_types = doc.root.add_element('listening')
            question = questions_types.add_element('question')
            q_id = question.add_element("id")
            branch_questions = question.add_element("branch_questions")
            branch_question = branch_questions.add_element("branch_question")
            b_id = branch_question.add_element("id")
            b_answer = branch_question.add_element("answer")
            q_id.add_text(question_id.to_s)
            b_id.add_text(branch_question_id.to_s)
            b_answer.add_text(answer.to_s)
          elsif types == 1
            count_q = 0 #计数大题
            count_b = 0 #计数小题
            doc.root.elements["reading"].each {|e|
              if e.class == REXML::Element && e.elements["id"].get_text.value.to_i == question_id
                count_q = 1
                e.elements["branch_questions"].each {|s|
                  if s.class == REXML::Element && s.elements["id"].get_text.value.to_i == branch_question_id
                    count_b = 1
                    p s.elements["id"].get_text.value.to_i
                    tmp = s.elements["answer"].get_text.value
                    p tmp
                    s.elements["answer"].remove()
                    anser = s.add_element("answer")
                    s = tmp.to_s + ";||;" + answer
                    anser.add_text(s)
                  end
                }
                if count_q == 1 && count_b == 0
                  branch_question = e.elements["branch_questions"].add_element("branch_question")
                  b_id = branch_question.add_element("id")
                  b_answer = branch_question.add_element("answer")
                  b_id.add_text(branch_question_id.to_s)
                  b_answer.add_text(answer.to_s)
                end
              end
            }
            if count_q == 0
              questions_types = doc.root.elements["reading"]
              question = questions_types.add_element('question')
              q_id = question.add_element("id")
              branch_questions = question.add_element("branch_questions")
              branch_question = branch_questions.add_element("branch_question")
              b_id = branch_question.add_element("id")
              b_answer = branch_question.add_element("answer")
              q_id.add_text(question_id.to_s)
              b_id.add_text(branch_question_id.to_s)
              b_answer.add_text(answer.to_s)
            end
          end
        else
          if types == 0
            count_q = 0 #计数大题
            count_b = 0 #计数小题
            doc.root.elements["listening"].each {|e|
              if e.class == REXML::Element && e.elements["id"].get_text.value.to_i == question_id
                count_q = 1
                e.elements["branch_questions"].each {|s|
                  if s.class == REXML::Element && s.elements["id"].get_text.value.to_i == branch_question_id
                    count_b = 1
                    p s.elements["id"].get_text.value.to_i
                    tmp = s.elements["answer"].get_text.value
                    p tmp
                    s.elements["answer"].remove()
                    anser = s.add_element("answer")
                    s = tmp.to_s + ";||;" + answer
                    anser.add_text(s)
                  end
                }
                if count_q == 1 && count_b == 0
                  branch_question = e.elements["branch_questions"].add_element("branch_question")
                  b_id = branch_question.add_element("id")
                  b_answer = branch_question.add_element("answer")
                  b_id.add_text(branch_question_id.to_s)
                  b_answer.add_text(answer.to_s)
                end
              end
            }
            if count_q == 0
              questions_types = doc.root.elements["listening"]
              question = questions_types.add_element('question')
              q_id = question.add_element("id")
              branch_questions = question.add_element("branch_questions")
              branch_question = branch_questions.add_element("branch_question")
              b_id = branch_question.add_element("id")
              b_answer = branch_question.add_element("answer")
              q_id.add_text(question_id.to_s)
              b_id.add_text(branch_question_id.to_s)
              b_answer.add_text(answer.to_s)
            end
          elsif types == 1
            count_q = 0 #计数大题
            count_b = 0 #计数小题
            doc.root.elements["reading"].each {|e|
              if e.class == REXML::Element && e.elements["id"].get_text.value.to_i == question_id
                count_q = 1
                e.elements["branch_questions"].each {|s|
                  if s.class == REXML::Element && s.elements["id"].get_text.value.to_i == branch_question_id
                    count_b = 1
                    p s.elements["id"].get_text.value.to_i
                    tmp = s.elements["answer"].get_text.value
                    p tmp
                    s.elements["answer"].remove()
                    anser = s.add_element("answer")
                    s = tmp.to_s + ";||;" + answer
                    anser.add_text(s)
                  end
                }
                if count_q == 1 && count_b == 0
                  branch_question = e.elements["branch_questions"].add_element("branch_question")
                  b_id = branch_question.add_element("id")
                  b_answer = branch_question.add_element("answer")
                  b_id.add_text(branch_question_id.to_s)
                  b_answer.add_text(answer.to_s)
                end
              end
            }

            if count_q == 0
              questions_types = doc.root.elements["reading"]
              question = questions_types.add_element('question')
              q_id = question.add_element("id")
              branch_questions = question.add_element("branch_questions")
              branch_question = branch_questions.add_element("branch_question")
              b_id = branch_question.add_element("id")
              b_answer = branch_question.add_element("answer")
              q_id.add_text(question_id.to_s)
              b_id.add_text(branch_question_id.to_s)
              b_answer.add_text(answer.to_s)
            end
          end

        end
        out = ""
        doc.write(out)
        p out.size
        #File.open(xml_file,"w")
        File.open(xml_file,"w+") do |f|
          f.write(out)
        end
        p have_listening
        p have_reading
      else #如果根元素下没有子元素，则不处理

      end
    end
    return true
  end

  #上传文件
  def upload_file destination_dir, rename_file_name, upload_file
    #参数:  destination_dir - 上传的目标目录，不包含文件url
    #       rename_file_name - 重命名的文件名
    #       file - 文件流
    #创建目录
    url = "/"
    dirs = destination_dir.split("/")
    dirs.delete("")
    dirs.each_with_index  do |e,i|
      url = url + "/" if i > 0
      url = url + "#{e}"
      Dir.mkdir url if !Dir.exist? url
    end


    upload_file.original_filename = rename_file_name +
        File.extname(avatar.original_filename).to_s if rename_file_name.gsub(" ","").size != 0
    file_url = "#{destination_dir}/#{upload_file.original_filename}"
    if upload_file.original_filename.nil? ||  destination_dir.gsub(" ","").size == 0
      return false
    else
      begin
        if File.open(file_url,"wb") do |f|
            f.write(upload_file.read)
          end
          return true
        else
          return false
        end
      rescue
        return false
      end
    end
  end

  #重建xml结构,转换成哈希后去掉冗余键
  def restruct_xml xml_string
    begin
      student_answers_xml = Hash.from_xml(xml_string)
    rescue
      questions_collections = nil
    end
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
