module MethodLibsHelper
  require 'rexml/document'
  require 'rexml/element'
  require 'rexml/parent'
  include REXML
  #记录答题json
  def write_answer_json dirs_url, answer_file_full_name, question_id, branch_question_id, answer, types
    #question_types 0:listening  1:reading
    status = false
    url = nil
    create_dirs dirs_url
    anwser_file_url = "#{dirs_url}/#{answer_file_full_name}"
    base_url = "#{Rails.root}/public"
    types = types.to_i
    if !File.exist? anwser_file_url #如果文件不存在，则创建文件和基本节点
      answer_records = {}
      branch_questions = []
      branch_questions << {:id => branch_question_id, :answer => answer}
      question = {:id => question_id, :branch_questions => branch_questions}
      answer_records[:listening] = []
      answer_records[:reading] = []
      if types == Question::TYPES[:LISTENING]
        answer_records[:listening] << question
      elsif types == Question::TYPES[:READING]
        answer_records[:reading] << question
      end
      answer_records = answer_records.to_json
      File.open(anwser_file_url,"w+") do |f|
        f.write(answer_records)
      end
      url = anwser_file_url.to_s[base_url.size,anwser_file_url.size]
      status = true
    else
      result = ""
      answer_json = ""
      File.open(anwser_file_url) do |file|
        file.each do |line|
          answer_json += line.to_s
        end
      end
      answer_records = ActiveSupport::JSON.decode(answer_json)
      count_question = 0
      count_branch_question = 0
      questions = answer_records[Question::TYPES_TITLE[types]]
        questions.each do |question|
          if question["id"].to_i == question_id.to_i
            count_question = 1
            question["branch_questions"].each do |branch_question|
              p branch_question["id"]
              if branch_question["id"].to_i == branch_question_id.to_i
                count_branch_question = 1
                break
              end
            end
            if count_question == 1 &&  count_branch_question == 0
              question["branch_questions"] << {"id" => branch_question_id, "answer" => answer}
            end
            break
          end
        end
        if count_question == 0
          answer_records[Question::TYPES_TITLE[types]] << {"id" => question_id,
                  "branch_questions" => [{"id" => branch_question_id, "answer" => answer}]}
        end
        result = answer_records
      result = result.to_json
      File.delete anwser_file_url
      File.open(anwser_file_url,"w") do |f|
        f.write(result)
      end
      url = anwser_file_url.to_s[base_url.size,anwser_file_url.size]
      status = true
    end
    info = {:status => status, :url => url}
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
    if upload_file && !upload_file.original_filename.nil?
      file = rename_file_name + File.extname(upload_file.original_filename).to_s if rename_file_name.gsub(" ","").size != 0
      file_url = "#{destination_dir}/#{file}"
      if upload_file.original_filename.nil? ||  destination_dir.gsub(" ","").size == 0
        status = false
        url = nil
      else
        begin
          if File.open(file_url,"wb") do |f|
              f.write(upload_file.read)
            end
            status = true
            url = file_url
          else
            status = false
            url = nil
          end
        rescue
          File.delete file_url if File.exist? file_url
          status = false
          url = nil
        end
      end
    else
      status = false
      url = nil
    end
    info = {:status => status, :url => url}
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

      if questions["reading"]["question"].present?
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

  #创建目录
  def create_dirs dirs_url
    #创建目录
    url = "/"
    count = 0
    dirs_url.split("/").each_with_index  do |e,i|
      if i > 0 && e.size > 0
        url = url + "/" if count > 0
        url = url + "#{e}"
        if !Dir.exist? url
          Dir.mkdir url
        end
        count = count +1
      end
    end
  end
  #生成题目包的xml
  def write_question_xml all_questions ,file_dirs_url, file_full_url
    status = false
    create_dirs file_dirs_url
    if File.exist? file_full_url #如果文件不存在，则创建文件和基本节点
      File.delete file_full_url
    end
    questions = ""
    doc = REXML::Document.new
    root_node = doc.add_element('questions')
    root_node.add_element('listening')
    root_node.add_element('reading')
    all_questions.each do |e|
      #question_types 0:listening  1:reading
      if e[:types] == Question::TYPES[:LISTENING]
        if doc.root.get_elements("listening").length > 0
          questions = doc.root.get_elements("listening")
        else
          questions = doc.root.add_element("listening")
        end
      elsif e[:types] == Question::TYPES[:READING]
        if doc.root.get_elements("reading").length > 0
          questions = doc.root.get_elements("reading")
        else
          questions = doc.root.add_element("reading")
        end
      end
      if questions[0].has_elements?
        count_question = 0
        questions[0].each do |question|
          if question.to_s.match(/^\<question\>.*/)
            if question.elements["id"].text.to_i == e[:id]
              count_question = 1
              count_branch_question = 0
              question.elements["branch_questions"].each do |branch_question|
                if branch_question.to_s.match(/^\<branch_question\>.*/)
                  if branch_question.elements["id"].text.to_i == e[:branch_question_id]
                    count_branch_question = 1
                  end
                end
              end
              if count_question == 1 && count_branch_question == 0
                branch_question = question.elements["branch_questions"].add_element("branch_question")
                branch_que_id = branch_question.add_element("id")
                branch_content = branch_question.add_element("content")
                branch_question_resource_url = branch_question.add_element("resource_url")
                branch_que_id.add_text("#{e[:branch_question_id]}")
                branch_content.add_text("#{e[:content]}")
                branch_question_resource_url.add_text("#{e[:resource_url]}")
              end
            end
          end
        end
      else
        question = questions[0].add_element("question")
        que_id = question.add_element("id")
        branch_questions = question.add_element("branch_questions")
        branch_question = branch_questions.add_element("branch_question")
        branch_que_id = branch_question.add_element("id")
        branch_content = branch_question.add_element("content")
        branch_question_resource_url = branch_question.add_element("resource_url")
        que_id.add_text("#{e[:id]}")
        branch_que_id.add_text("#{e[:branch_question_id]}")
        branch_content.add_text("#{e[:content]}")
        branch_question_resource_url.add_text("#{e[:resource_url]}")
      end
      if count_question == 0
        question = questions[0].add_element("question")
        que_id = question.add_element("id")
        branch_questions = question.add_element("branch_questions")
        branch_question = branch_questions.add_element("branch_question")
        branch_que_id = branch_question.add_element("id")
        branch_content = branch_question.add_element("content")
        branch_question_resource_url = branch_question.add_element("resource_url")
        que_id.add_text("#{e[:id]}")
        branch_que_id.add_text("#{e[:branch_question_id]}")
        branch_content.add_text("#{e[:content]}")
        branch_question_resource_url.add_text("#{e[:resource_url]}")
      end
    end
    #写文件
    xml_str = ""
    doc.write(xml_str)
    questions_json = questions_xml_to_json xml_str
    questions_json = questions_json.to_json
    if File.open(file_full_url,"w+") do |f|
      f.write(questions_json)
    end
      status = true
    else
      status = false
    end
    write_file = {:status => status}
  end

  #将生成的题目包xml转换为json
  def questions_xml_to_json xml_str
    questions_collections = nil
    begin
      student_answers_xml = Hash.from_xml(xml_str)
    rescue
      questions_collections = nil
    end
    if student_answers_xml["questions"].present?
      questions = student_answers_xml["questions"]
      if questions["listening"].present?
        lisenting_questions = questions["listening"]["question"]  #听力题
        #如果听力或朗读题只有一题,则将该题目的哈希转换为数组
        if lisenting_questions.class == Hash  #如果听力题中的题目只有一题,将哈希转为数组
          tmp = lisenting_questions
          lisenting_questions = []
          lisenting_questions << tmp
          #重组哈希,去掉question键和branch_question键
        end
        lisentings = []
        lisenting_questions.each do |question|
          branch_questions = []
          if question["branch_questions"]["branch_question"].class == Hash
            branch_questions << question["branch_questions"]["branch_question"]
          else
            question["branch_questions"]["branch_question"].each do |e|
              branch_questions << e
            end
          end
          lisentings << {"id" => question["id"], "branch_questions" => branch_questions}
        end
      end
      if questions["reading"].present?
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
          if question["branch_questions"]["branch_question"].class == Hash
            branch_questions << question["branch_questions"]["branch_question"]
          else
            question["branch_questions"]["branch_question"].each do |e|
              branch_questions << e
            end
          end
          readings << {"id" => question["id"], "branch_questions" => branch_questions}
        end
      end
      p lisentings
      p readings
      if lisentings.length > 0 && readings.length > 0
        questions_collections = {"listening"=> lisentings,"reading" => readings}
      elsif lisentings.length > 0 && readings.length = 0
        questions_collections = {"listening"=> lisentings}
      elsif lisentings.length = 0 && readings.length > 0
        questions_collections = {"reading" => readings}
      end
    else
      questions_collections = nil
    end
    questions_collections
  end
end
