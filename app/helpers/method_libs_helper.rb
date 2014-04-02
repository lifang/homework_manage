#encoding: utf-8
module MethodLibsHelper
  require 'rexml/document'
  require 'rexml/element'
  require 'rexml/parent'
  require 'net/http'
  include REXML
  #记录答题json
  def write_answer_json dirs_url, answer_file_full_name, question_id, branch_question_id, answer, types
    #question_types 0:listening  1:reading
    status = false
    url = nil
    root_path = "#{Rails.root}/public/"
    create_dirs dirs_url
    anwser_file_url = "#{root_path + dirs_url}/#{answer_file_full_name}"
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
      begin
        File.open(anwser_file_url,"w+") do |f|
          f.write(answer_records)
        end
        url = anwser_file_url.to_s[base_url.size,anwser_file_url.size]
        status = true
      rescue
        url = nil
        status = false
      end
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
      questions.each do |q|
        if q["id"].to_i == question_id.to_i
          count_question = 1
          q["branch_questions"].each do |branch_question|
            if branch_question["id"].to_i == branch_question_id.to_i
              count_branch_question = 1
              break
            end
          end
          if count_question == 1 &&  count_branch_question == 0
            q["branch_questions"] << {"id" => branch_question_id, "answer" => answer}
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
      File.delete anwser_file_url if anwser_file_url
      File.open(anwser_file_url,"w") do |f|
        f.write(result)
      end
      url = anwser_file_url.to_s[base_url.size,anwser_file_url.size]
      status = true
    end
    info = {:status => status, :url => url}
  end
  #上传文件
  def upload_file dirs_url, rename_file_name, file
    #参数:  destination_dir - 上传的目标目录，不包含文件全名
    #       rename_file_name - 重命名的文件基本名，不包含拓展名
    #       file - 文件
    root_path = "#{Rails.root}/public/"
    create_dirs dirs_url
    if file && !file.original_filename.nil?
      file_full_name = rename_file_name + File.extname(file.original_filename).to_s
      file_url = "#{root_path + dirs_url}/#{file_full_name}"
      if file.original_filename.nil? ||  dirs_url.gsub(" ","").size == 0
        status = false
        url = nil
      else
        begin
          if File.open(file_url,"wb") do |f|
              f.write(file.read)
            end
            status = true
            unuse_url = "#{Rails.root}/public"
            url = file_url.to_s[unuse_url.size,file_url.size]
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

  def create_dirs dirs_url
    #    url = ""
    dir_dull_path = "#{Rails.root}/public/" + dirs_url
    FileUtils.mkdir_p(dir_dull_path) unless Dir.exists?(dir_dull_path)
    #    dirs = dirs_url.split("/")
    #    dirs.each_with_index  do |e,i|
    #      url +=  "/"
    #      url += "#{e}"
    #      Dir.mkdir root_path + url if !Dir.exist? root_path + url
    #    end
  end

  #生成题目包的xml
  def write_question_xml all_questions ,file_dirs_url, file_full_name
    status = false
    create_dirs file_dirs_url
    file_url = "#{Rails.root}/public/#{file_dirs_url}/#{file_full_name}"
    if File.exist? file_url #如果文件不存在，则创建文件和基本节点
      File.delete file_url
    end
    questions = ""
    doc = REXML::Document.new
    root_node = doc.add_element('questions')
    
    Question::TYPE_NAME_ARR.each{|type_name| root_node.add_element(type_name)}
    #    root_node.add_element('listening')
    #    root_node.add_element('reading')
    all_questions.each do |e|
      #question_types 0:listening  1:reading
      #      if e[:types] == Question::TYPES[:LISTENING]
      #        questions = doc.root.get_elements("listening")
      #      elsif e[:types] == Question::TYPES[:READING]
      #        questions = doc.root.get_elements("reading")
      #      end
      questions = doc.root.get_elements(Question::TYPES_TITLE[e[:types]]) #得到某个题型下面的节点
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
                branch_question_options = branch_question.add_element("options")
                branch_question_answer = branch_question.add_element("answer")
                branch_question_resource_url = branch_question.add_element("resource_url")
                branch_que_id.add_text("#{e[:branch_question_id]}")
                branch_content.add_text("#{e[:content]}")
                branch_question_resource_url.add_text("#{e[:resource_url].present? ? e[:resource_url].split("/")[-1] : ''}")
                branch_question_options.add_text("#{e[:options].present? ? e[:options] : ''}")
                branch_question_answer.add_text("#{e[:answer].present? ? e[:answer]: ''}")
              end
            end
          end
        end
      else
        question = questions[0].add_element("question")
        add_one_question_node question, e
      end
      if count_question == 0
        question = questions[0].add_element("question")
        add_one_question_node question, e
      end
    end
    #写文件
    xml_str = ""
    doc.write(xml_str)
    #File.open(Rails.root.to_s + "/public/1.xml", "wb"){|f| f.write xml_str}
    questions_json = questions_xml_to_json xml_str
    questions_json = questions_json.to_json
    if File.open(file_url,"w+") do |f|
        f.write(questions_json)
      end
      status = true
    else
      status = false
    end
    write_file = {:status => status}
  end

  #生成题目包的xml时追加一个大题节点
  def add_one_question_node question_node, question_params_obj
    que_id = question_node.add_element("id")
    que_use_time = question_node.add_element("questions_time")
    que_full_text = question_node.add_element("full_text")  #完型填空用到
  
    branch_questions = question_node.add_element("branch_questions")
    branch_question = branch_questions.add_element("branch_question")
    branch_que_id = branch_question.add_element("id")
    branch_content = branch_question.add_element("content")
    branch_question_resource_url = branch_question.add_element("resource_url")
    branch_question_options = branch_question.add_element("options")
    branch_question_answer = branch_question.add_element("answer")
    
    que_id.add_text("#{question_params_obj[:id]}")
    que_use_time.add_text("#{question_params_obj[:questions_time].present? ? question_params_obj[:questions_time] : ''}")
    que_full_text.add_text("#{question_params_obj[:full_text].present? ? question_params_obj[:full_text] : ''}")
    
    branch_que_id.add_text("#{question_params_obj[:branch_question_id]}")
    branch_content.add_text("#{question_params_obj[:content]}")
    branch_question_resource_url.add_text("#{question_params_obj[:resource_url].present? ? question_params_obj[:resource_url].split('/')[-1] : ''}")
    branch_question_options.add_text("#{question_params_obj[:options].present? ? question_params_obj[:options] : ''}")
    branch_question_answer.add_text("#{question_params_obj[:answer].present? ? question_params_obj[:answer]: ''}")
  end

  #将生成的题目包xml转换为json
  def questions_xml_to_json xml_str
    questions_collections = nil
    begin
      student_answers_xml = Hash.from_xml(xml_str)
    rescue
      questions_collections = nil
    end
    #    lisentings = []
    #    readings = []

    tmp_questions_collections = {}
    Question::TYPE_NAME_ARR.map{|arr1| tmp_questions_collections[arr1] = {}}
    
    #    Question::TYPE_NAME_ARR.each do |question_type|
    if student_answers_xml["questions"].present?
      questions = student_answers_xml["questions"]
      questions.each do |key,value|
        if questions[key].present?
          ques = questions["#{key}"]["question"]
          #如果听力或朗读题只有一题,则将该题目的哈希转换为数组
          if ques.class == Hash
            tmp = ques
            ques = []
            ques << tmp
            #重组哈希,去掉question键和branch_question键
          end
          tmp_questions_collections[key][:specified_time] = ques.inject(0){|sum, q| sum+= q["questions_time"].to_i; sum}
          tmp_questions_collections[key][:questions] ||= []
          ques.each do |q|
            if q["branch_questions"]["branch_question"].class == Hash
              branch_questions = []
#              if key == "lining"  #连线题特殊处理
#                one_lining_branch_que_options = q["branch_questions"]["branch_question"]["options"].split(";||;").join("<=>");
#                q["branch_questions"]["branch_question"]["content"] = one_lining_branch_que_options
#              end
              branch_questions << q["branch_questions"]["branch_question"]
            else
#              if key == "lining"   #连线题特殊处理
#                branch_questions = []
#                lining_content = []
#                q["branch_questions"]["branch_question"].each do |bq_hash|
#                  lining_content << bq_hash["options"].split(";||;").join("<=>");
#                end
#                lining_content = lining_content.join(";||;")
#                branch_question = q["branch_questions"]["branch_question"][0].dup
#                branch_question["content"] = lining_content
#                branch_questions << branch_question
#              else
                branch_questions = q["branch_questions"]["branch_question"]
#              end
            end
            tmp_questions_collections[key][:questions] << {"id" => q["id"], "full_text" => q['full_text'], "branch_questions" => branch_questions}
            #              lisentings << {"id" => q["id"], "branch_questions" => branch_questions}  if key == "listening"
            #              readings << {"id" => q["id"], "branch_questions" => branch_questions}  if key == "reading"
          end
        end
      end
      #if lisentings.length > 0 && readings.length > 0
      questions_collections = tmp_questions_collections
      #elsif lisentings.length > 0 && readings.length == 0
      #  questions_collections = {"listening"=> lisentings}
      #elsif lisentings.length == 0 && readings.length > 0
      #  questions_collections = {"reading" => readings}
      #end
    else
      questions_collections = nil
    end
    questions_collections
  end
  
  def narrow_picture file_path,rename_file_name,filename,destination_dir
    avatar_url = nil
    img = MiniMagick::Image.open file_path,"rb"
    if img[:height]>Teacher::AVATAR_SIZE[0] || img[:width] > Teacher::AVATAR_SIZE[0]
      Teacher::AVATAR_SIZE.each do |size|
        resize = size>img["width"] ? img["width"] :size
        new_file = file_path.split(".")[0]+"_"+resize.to_s+"."+file_path.split(".").reverse[0]
        resize_file_name = rename_file_name+"_176"+filename[/\.[^\.]+$/]
        avatar_url =  '/'+destination_dir+ '/' +resize_file_name
        img.run_command("convert #{file_path} -resize #{resize}x#{resize} #{new_file}")
      end
    else
      avatar_url = '/'+destination_dir+'/'+rename_file_name + filename[/\.[^\.]+$/]
    end
    avatar_url
  end

  def jpush_parameter messages,receivervalue,extras_hash=nil
    input ="#{Micropost::JPUSH[:SENDNO]}" + "#{Micropost::JPUSH[:RECEIVERTYPE]}" + receivervalue + Micropost::JPUSH[:MASTERSECRET]
    code = Digest::MD5.hexdigest(input)
    #msg_content =  "{\"n_title\":\"1111222\",\"n_content\":#{messages},\"n_extras\":{\"class_id\":\"2\"} }"  Jpush消息格式
    content = {"n_content" => "#{messages}","n_title"=> "超级作业本"}
#    content = {"n_content" => "#{messages}","n_title"=> "2iidid"}
    content["n_extras"]=extras_hash if !extras_hash.nil? && extras_hash.class == Hash
    msg_content = content.to_json()
    map = Hash.new
    map.store("sendno", Micropost::JPUSH[:SENDNO])
    map.store("app_key", Micropost::JPUSH[:APP_KEY])
    map.store("receiver_type", Micropost::JPUSH[:RECEIVERTYPE])
    map.store("receiver_value",receivervalue)
    map.store("verification_code", code)
    map.store("msg_type",Micropost::JPUSH[:MSG_TYPE])
    map.store("msg_content",msg_content)
    map.store("platform", Micropost::JPUSH[:PLATFORM])
    data =  (Net::HTTP.post_form(URI.parse(Micropost::JPUSH[:URI]), map)).body
  end

  def push_after_reply_post content, teachers_id, reciver_id, school_class_id, student, reciver_types
    unless teachers_id.include?(reciver_id.to_i)
      if reciver_types == Micropost::USER_TYPES[:STUDENT] && !student.nil?  #?  TODO reciver_types == 1 学生
        extras_hash = {:type => Student::PUSH_TYPE[:q_and_a], :class_id => school_class_id}
        token = student.token
        if token
          ipad_push(content, [token], extras_hash)
        else
          qq_uid = student.qq_uid
          jpush_parameter content, qq_uid, extras_hash
        end
        #android_and_ios_push(school_class,content,extras_hash)
      end
    end
  end
  
  #删除提示消息和系统消息
  def is_delete_message user_id, school_class_id, message
    user = User.find_by_id user_id
    school_class = SchoolClass.find_by_id school_class_id
    student = user.student if user.present?
    if user.nil? || school_class.nil?
      status = "error"
      notice = "用户或班级信息错误,请重新登陆!"
    else
      if student.nil?
        status = "error"
        notice = "用户信息错误,请重新登陆!"
      else
        school_class_student_relations = SchoolClassStudentRalastion.
          find_by_student_id_and_school_class_id student.id, school_class.id
        if school_class_student_relations.nil?
          status = "error"
          notice = "用户与班级的关系不正确,请重新登陆!"
        else
          if message.nil?
            status = "error"
            notice = "消息不存在!"
          else
            if message.destroy
              status = "success"
              notice = "删除成功!"
            else
              status = "error"
              status = "删除失败!"
            end
          end
        end
      end
    end
    info = {:status => status, :notice => notice}
  end

  #列出卡包所有卡片的列表#根据分类查询列出卡包卡片的列表api
  def knowledges_card_list student_id,school_class_id,mistake_types=nil
    card_bag = CardBag.find_by_student_id_and_school_class_id student_id, school_class_id
    if card_bag.blank?
      status = "error"
      notice = "卡包不存在"
      knowledges_card = nil
    else
      card_bag_id = card_bag.id
      sql = "SELECT kc.*,bq.content,bq.question_id,bq.resource_url,bq.types,bq.answer,bq.options,q.full_text,q.id question_id
FROM knowledges_cards kc INNER JOIN branch_questions bq on kc.branch_question_id = bq.id LEFT JOIN questions q on
q.id = bq.question_id where kc.card_bag_id = ?"
      if mistake_types.nil?
        knowledge_cards = KnowledgesCard.find_by_sql([sql,card_bag_id])
      else
        mistake_types_sql = " and kc.mistake_types=?"
        sql += mistake_types_sql
        knowledge_cards = KnowledgesCard.find_by_sql([sql,card_bag_id,mistake_types])
      end
      knowledge_content = process_knowledges knowledge_cards,card_bag_id
      status = knowledge_content[:status]
      notice = knowledge_content[:notice]
      knowledges_cards = knowledge_content[:knowledges_cards]
      cardtag = knowledge_content[:cardtag]
    end
    info = {:status => status,:notice => notice,:knowledges_card => knowledges_cards,:tags => cardtag }
  end

  #处理knowledge_card 数据
  def process_knowledges knowledge_cards,card_bag_id
    branch_id = []
    knowledge = knowledge_cards.group_by{ |knowledge_card| knowledge_card.types }
    knowledge.each do |types,knowledge_card|
      if  types==Question::TYPES[:CLOZE]
        knowledge_card.map(&:question_id).each do |arr_br_id|
          branch_id << arr_br_id
        end
      end
    end
    branch_questions = BranchQuestion.where("question_id in (?)",branch_id).select("content,answer,question_id")
    branch_questions_arr = branch_questions.group_by{|branch_question|branch_question.question_id}
    knowledge_cards.each do |knowledg|
      branch_questions_arr.each do |question_id,branch_question|
        if knowledg.question_id == question_id
          knowledg.answer = branch_question
        end
      end
    end
    cardtag = CardTag.where("card_bag_id = #{card_bag_id}")
    cardtag_kcard_relation = CardTagKnowledgesCardRelation.where("card_tag_id in (?)" ,cardtag.map(&:id)).
      group_by{|cardtag_kcard| cardtag_kcard.knowledges_card_id}
    knowledges_cards = []
    knowledge_cards.each do |knowledges_card|
      know =  knowledges_card.attributes
      know['card_tags_id']=[]
      cardtag_kcard_relation.each do |knowledges_card_id,cardtag_kcard|
        if knowledges_card.id.eql?(knowledges_card_id)
          know['card_tags_id'] = cardtag_kcard.map(&:card_tag_id)
        end
      end
      knowledges_cards << know
    end
    status = "success"
    notice = "获取成功！！"
    knowledge_content = {:status=>status,:notice=>notice,:knowledges_cards=>knowledges_cards,:cardtag=>cardtag}
  end

  #  通过错题类型或者标签名称查询
  def knowledges_andcards_tolist school_class_id,student_id,name
    cardbag = CardBag.find_by_school_class_id_and_student_id school_class_id,student_id
    knowledgescard = []
    if cardbag
      cardbag_id = cardbag.id
      sql = "SELECT DISTINCT kc.*,bq.content,bq.question_id,bq.resource_url,bq.types,bq.answer,bq.options,q.id question_id
 from knowledges_cards kc  inner join card_tag_knowledges_card_relations ctkcr on kc.id = ctkcr.knowledges_card_id
INNER JOIN card_tags ct on ct.id = ctkcr.card_tag_id
INNER JOIN branch_questions bq on kc.branch_question_id = bq.id
inner join questions q on  q.id = bq.question_id
WHERE kc.card_bag_id =? and ct.name LIKE ? or kc.your_answer LIKE ? "
      knowledgescard = KnowledgesCard.find_by_sql([sql,cardbag_id,name,name])

      knowledge_content = process_knowledges knowledgescard,cardbag_id
      status = knowledge_content[:status]
      notice = knowledge_content[:notice]
      knowledges_cards = knowledge_content[:knowledges_cards]
      cardtag = knowledge_content[:cardtag]
    else
      status = "error"
      notice = "卡包不存在"
    end
    info = {:status=>status,:notice=>notice,:knowledgescard => knowledges_cards,:tags => cardtag }
  end


  #压缩和推送
  def compress_and_push file_dirs_url,question_package_id,school_class,content,publish_question_package
    zip_url = "#{Rails.root}/public/#{file_dirs_url}/resourse.zip"
    File.delete zip_url if File.exists?(zip_url)
    resourse_url = "#{Rails.root}/public#{media_path % question_package_id}"
    question_packages_url = "#{Rails.root}/public#{publish_question_package.question_packages_url}"
    resourse_zip_url = "/#{file_dirs_url}/resourse.zip"
    Archive::Zip.archive("#{zip_url}","#{resourse_url}/.") if Dir.exists?(resourse_url)
    if File.exist?(question_packages_url)
      Archive::Zip.archive("#{zip_url}","#{question_packages_url}")
      publish_question_package.update_attributes(:question_packages_url => resourse_zip_url)
    end
    #    sql = "SELECT s.alias_name FROM students s ,school_class_student_ralastions  scsr ,school_classes sc
    #WHERE s.id = scsr.student_id and scsr.school_class_id = sc.id and sc.id = ?#"
    #    student = Student.find_by_sql([sql,school_class_id])
    
    publish_android_and_ios_push(school_class,content,publish_question_package.tag_id) #传tag参数，为了给对应分组的学生发送推送
   
  end

  def publish_android_and_ios_push(school_class,content, tag_id=nil)
    #安卓推送
    if tag_id.present? and tag_id == 0  #未分组，默认为0
      android_student_qq_uid = school_class.students.where("token is null ").select("qq_uid").map(&:qq_uid)
    else
      android_student_qq_uid = school_class.students.where("token is null and school_class_student_ralastions.tag_id = #{tag_id}").select("qq_uid").map(&:qq_uid)
    end
    qq_uids = android_student_qq_uid.join(",")
    extras_hash = {:type => Student::PUSH_TYPE[:publish_question, :class_id => school_class.id]}
    jpush_parameter content, qq_uids, extras_hash

    #ios 推送
    if tag_id.present? && tag_id != 0  #分组
      ipad_student_tokens = school_class.students.where("token is not null  and school_class_student_ralastions.tag_id = #{tag_id}").select("token").map(&:token)
    else
      ipad_student_tokens = school_class.students.where("token is not null").select("token").map(&:token)
    end
    ipad_push(content, ipad_student_tokens, extras_hash)
  end


  def ipad_push(content, ipad_student_tokens, extras_hash)
    APNS.host = 'gateway.sandbox.push.apple.com'
    APNS.pem  = File.join(Rails.root, 'config', 'cjzyb_dev.pem')
    APNS.port = 2195
    token = ipad_student_tokens
    notification_arr = []
    ipad_student_tokens.each do |token|
      notification_arr << APNS::Notification.new(token, :alert => content, :badge => 1, :sound => "default", :other => extras_hash) if token.present?  #把提醒类型值【0,1,2】放在sound里面
    end
    APNS.send_notifications(notification_arr) if notification_arr.present?
  end

end
