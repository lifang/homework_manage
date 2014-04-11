#encoding: utf-8
include QuestionPackagesHelper
include MethodLibsHelper
class QuestionPackagesController < ApplicationController
  before_filter :get_cells_and_episodes, :only => [:new, :render_new_question]
  before_filter :get_school_class
  def index
    respond_to do |f|
      #分享题目的分�?
      f.js{
        @question_pack = QuestionPackage.find_by_id(params[:question_package_id])
        @question = Question.find_by_id(params[:question_id])
        @sort_name = params[:sort_name]
        sort = @sort_name == "up" ? "asc" : "desc"
        @share_questions = ShareQuestion.share_questions(@question.cell_id, @question.episode_id, @question.types, sort, params[:page])
        @href = "/question_packages?question_package_id=#{@question_pack.id}&question_id=#{@question.id}"
      }
      f.html
    end
  end

  #导入听写题
  def inport_lisenting
    question_package_id = params[:question_package_id]  
    question_id = params[:question_id]  
    file = params[:file]
    @status = false
    if question_package_id.present?
      destination_dir = "#{media_path % question_package_id}".gsub(/^[^\\]|[^\\]$/, "")
      unzip_url = "#{destination_dir}/question_#{question_id}"
      create_dirs unzip_url
      zip_url = "#{Rails.root}/public/#{destination_dir}/question_#{question_id}"
      rename_file_name = "question_#{question_id}"
      upload = upload_file destination_dir, rename_file_name, file
      if upload[:status] == true
          if unzip(zip_url) == true
            files = get_excel_and_audio(zip_url)
            excel = files[:excel]
            audios = files[:audios]
            if excel.size <= 0
              @notice = "没有找到excel题目文件!"
            else
                #获取excel中题目的错误信息
                excel_url = "#{zip_url}/#{excel}" 
                result  = read_questions zip_url, excel_url, audios
                p result
                if result[:errors].any?
                  @status = "errors"
                else
                  @questions = result[:errors]
                end  
            end
            p excel
            p audios
            @status = true
          else
            @notice = "解压出错！"
          end
      else
        @notice = "上传出错！"
      end    
    end
  end  

  #朗读/听写题先上传音频文件
  def upload_voice
    file = params[:file]
    question_package_id = params[:question_package_id]
    question_package = QuestionPackage.find_by_id question_package_id
    question_id = params[:question_id]
    branch_id = params[:branch_id]
    @question = Question.find_by_id question_id
    @b_index = params[:b_index]
    @status = false
    if file && file.size > 1048576
      @notice = "文件不能超过1M！" 
    else
      if question_package && @question && @b_index
        destination_dir = "#{media_path % question_package.id}".gsub(/^[^\\]|[^\\]$/, "")
        rename_file_name = "media_#{Time.now.strftime("%Y-%m-%d_%H_%M_%S")}_que_#{question_id}"
        upload = upload_file destination_dir, rename_file_name, file
        if upload[:status] == true
          @resource_url = upload[:url]
          if branch_id.present?
            branch_question = BranchQuestion.find_by_id branch_id
            if branch_question.present?
              if branch_question.update_attributes(:resource_url => @resource_url)
                @status = true
                @notice = "文件上传完成！"
              else
                @status = false
                @notice = "文件上传失败！"
              end  
            else
              @status = false
              @notice = "该小题不存在,文件上传失败！"   
            end
          else
            @status = true
            @notice = "文件上传完成！"
          end  
        else
          @notice = "文件上传失败！" 
        end
      else
        @notice = "文件上传失败！"   
      end  
    end  
  end  

  #显示听力或朗读题
  def show_questions
    types = params[:types]
    question_package_id = params[:question_package_id]
    episode_id = params[:episode_id]
    cell_id = params[:cell_id]
    que_sql = ""
    @question =  Question.find_by_sql que_sql
  end 

  #新建朗读题/听力题
  def new_reading_or_listening
    teacher = Teacher.find_by_id cookies[:teacher_id].to_i
    @user = teacher.user
    @question = Question.create(:types => params[:types].to_i,
      :question_package_id => params[:question_package_id].to_i,
      :cell_id => params[:cell_id].to_i,
      :episode_id => params[:episode_id].to_i)
    @types = @question.types
  end

  #删除听力或朗读小题
  def delete_branch
    branch_question_id = params[:branch_question_id]
    branch_question = BranchQuestion.find_by_id branch_question_id
    status = 0
    if branch_question
      BtagsBqueRelation.delete_all("branch_question_id = #{branch_question_id}")
      resource_url = "#{Rails.root}/public#{branch_question.resource_url}"
      File.delete resource_url if branch_question.resource_url.present? && File.exist?(resource_url)
      branch_question.destroy
      status = 1
    end 
    render :json => {:status=> status}
  end  

  #更新听力题
  def update_listening
    branch_id = params[:branch_id]
    branch_question = BranchQuestion.find_by_id branch_id
    status = false
    @notice = "该小题不存在，修改失败！"
    if branch_question.present?
      if branch_question.update_attributes(:content => params[:content]) 
        status = true
        notice = "小题修改成功！"  
      else
        notice = "小题修改失败！"
      end
    end
    render :json => {:status => status, :notice => notice}
  end  

  #创建听力题小题
  def save_listening
    @q_index = params[:q_index].to_i
    @b_index = params[:b_index].to_i
    tags_id = params[:tags_id]
    types = params[:types]
    file = params[:file]
    branch_id = params[:branch_id]
    @status = -2
    @notice = "小题创建失败！"
    if types.present?
      @types = types.to_i
      @question = Question.find_by_id params[:question_id].to_i
      @question_id = @question.id      
      content = params[:content]
      if file.present?
        @branch_question = BranchQuestion.create(:content => content, :question_id => @question_id, 
                          :types => types.to_i, :resource_url => file)
        if @branch_question.present?
          @status = 1
          @notice = "小题创建成功！"
        end
      else
        @notice = "听写题资源不能为空！"
      end
    end  
  end 
  
  #创建朗读题小题
  def save_reading
    @q_index = params[:q_index].to_i
    @b_index = params[:b_index].to_i
    tags_id = params[:tags_id]
    types = params[:types]
    file = params[:file]
    if types.present?
      @types = types.to_i
      @question = Question.find_by_id params[:question_id].to_i
      @question_id = @question.id
      branch_id = params[:branch_id]
      if branch_id.present?
        @branch_question = BranchQuestion.find_by_id branch_id
        if @branch_question.nil?
          @status = -1
          @notice = "该小题不存在，修改失败！"
        else
          if params[:content].present?
            if @branch_question.update_attributes(:content => params[:content] )
              @status = 0
              @notice = "小题修改成功！"
            else
              @status = -1
              @notice = "小题修改失败！"
            end
          end
        end
      else
        @status = -2
        @notice = "小题创建失败！"
        content = params[:content]
        if file.present?
          @branch_question = BranchQuestion.create(:content => content, :question_id => @question_id, 
                            :types => types.to_i, :resource_url => file)
        else
          @branch_question = BranchQuestion.create(:content => content, :question_id => @question_id, 
                            :types => types.to_i)
        end    
        if @branch_question.present?
          @status = 1
          @notice = "小题创建成功！"
        end
      end
    else
      @status = -1
      @notice = "该小题不存在数据错误，题型不能为空！" 
    end
  end 

  def new
    @question_pack = QuestionPackage.create(:school_class_id => @school_class.id)
    redirect_to "/school_classes/#{@school_class.id}/question_packages/#{@question_pack.id}/new_index"
  end
  
  def new_index
    @b_tags = get_branch_tags(cookies[:teacher_id])
    teacher = Teacher.find_by_id cookies[:teacher_id]
    @user = teacher.user
    @question_pack = QuestionPackage.find_by_id(params[:id])
    @question_type = Question::TYPES_NAME
    @cells = Cell.where("teaching_material_id = ?",@school_class.teaching_material_id )
    @questions = Question.where(["question_package_id=?", @question_pack.id])
    #{qid => [branch_question,branch_question,branch_question], qid =>...}
    branch_questions = BranchQuestion.where(["question_id in (?)", @questions.map(&:id)])
    @branch_questions = branch_questions.group_by{|bq|bq.question_id}
    branch_tags = BtagsBqueRelation.find_by_sql(["select bt.name, bbr.id, bbr.branch_question_id, bbr.branch_tag_id,bq.question_id  from
        btags_bque_relations bbr left join branch_tags bt on bbr.branch_tag_id=bt.id left join branch_questions bq
        on bq.id = bbr.branch_question_id where bbr.branch_question_id in (?)", branch_questions.map(&:id)])
    h_branch_tags = branch_tags.group_by{|t|t.question_id} #{bqid => [tag,tag,tag],bqid => [tag,tag,tag]}
    hash = {}
    h_branch_tags.each do |k, v|
      second_tags = v.group_by{|t|t.branch_question_id}
      hash[k] = second_tags
    end
    @branch_tags = hash
    unless @questions[0].nil?
      @question_exist = @questions[0]
      unless @question_exist.episode_id.nil?
        @exist_episode = Episode.find_by_id(@question_exist.episode_id) unless @question_exist.episode_id.nil?
        @exist_cell = Cell.find_by_id(@exist_episode.cell_id) unless @exist_episode.cell_id.nil?
      end
    end
    #引用题目的url
    @reference_part_url = "/school_classes/#{@school_class.id}/share_questions/list_questions_by_type?question_pack_id=#{params[:id]}"
    render 'new'
  end
  
  def setting_episodes
    @cells = Cell.find_by_id(params[:cell_id])
    @episodes = @cells.episodes
  end
  #show完形填空
  def show_wanxin
    episode_id = params[:episode_id]
    @question_packages = QuestionPackage.find_by_id(params[:id])
    @questions = Question.where("types = ? and question_package_id = ? and episode_id = ?",
      Question::TYPES[:CLOZE],
      @question_packages.id,
      episode_id)
  end
  def create_wanxin
    cell_id = params[:cell_id]
    episode_id = params[:episode_id]
    @question_packages = QuestionPackage.find_by_id(params[:id])
    @wanxin_index = get_count_of_wanxin @question_packages.questions
    @question = Question.create(types:Question::TYPES[:CLOZE],
      question_package_id:@question_packages.id,
      episode_id:episode_id,
      cell_id:cell_id)
  end
  
  def show_ab_list_box
    @index = params[:index]
    @question_packages = QuestionPackage.find_by_id(params[:id])
    @question_id = params[:question_id]
    @branch_questions = BranchQuestion.where("question_id = ?",params[:question_id])
    @options = @branch_questions.map{|d| d.options.split(";||;")}
    @values=[]
    @branch_questions.each_with_index do |bq|
      @values << bq.options.split(";||;").index { |x| x == bq.answer }
    end

    branch_question_ids = @branch_questions.map(&:id)
    @tags = BtagsBqueRelation.where("branch_question_id in (?)",branch_question_ids).
      joins("inner join branch_tags bt on btags_bque_relations.branch_tag_id=bt.id").
      select("btags_bque_relations.id,btags_bque_relations.branch_question_id,bt.name,bt.created_at,bt.updated_at")

  end
  def unencode content
    arr = ['&#60;','&#34;','&#59;','&#62;','&#38;','&#39;','&#35;']
    arr_encode = ['<','"',';','>','&','\'','#']
    7.times do |i|
      content = content.gsub(arr[i],arr_encode[i]);
    end
    content
  end
  def save_wanxin_content
    content = params[:content].gsub("(**)","&#").gsub("(*:*)",";").html_safe;
    content = unencode content
    content = content.gsub("&nbsp;"," ")
    @question = Question.find_by_id(params[:id])
    if @question.update_attribute(:full_text, content)
      render text:1
    else
      render text:0
    end
  end

  def save_wanxin_branch_question
    
    @gloab_index = params[:gloab_index]
    branch_question_id = params[:branch_question_id]
    option = params[:option]
    options = option.join(";||;")
    index =-1
    params.each do |t|
      if t[0] =~ /radio_/
        index = t[1].to_i
      end
    end
    answer = option[index]
    if branch_question_id==""
      if BranchQuestion.create(question_id:params[:question_id],
          options:options,
          answer:answer,
          types:Question::TYPES[:CLOZE])
        @text=1
      else
        @text=0
      end
    else
      branch_question = BranchQuestion.find_by_id(branch_question_id)
      if branch_question.update_attributes(options:options,
          answer:answer
        )
        @text=2
      else
        @text=0
      end
    end
    @question_packages = QuestionPackage.find_by_id(params[:id])
    @question_id = params[:question_id]
    @branch_ques = BranchQuestion.where("question_id = ?",params[:question_id])
    @options = @branch_ques.map{|d| d.options.split(";||;")}
    @values=[]
    @branch_ques.each_with_index do |bq|
      @values << bq.options.split(";||;").index { |x| x == bq.answer }
    end
    branch_question_ids = @branch_ques.map(&:id)
    @tags = BtagsBqueRelation.where("branch_question_id in (?)",branch_question_ids).
      joins("inner join branch_tags bt on btags_bque_relations.branch_tag_id=bt.id").
      select("btags_bque_relations.id,btags_bque_relations.branch_question_id,bt.name,bt.created_at,bt.updated_at")
  end
  
  def delete_wanxin_branch_question
    branch_question_id = params[:branch_question_id]
    delete_branch_question branch_question_id
    @index = params[:index]
    @question_packages = QuestionPackage.find_by_id(params[:id])
    @branch_ques = BranchQuestion.where("question_id = ?",params[:question_id])
    @options = @branch_ques.map{|d| d.options.split(";||;")}
    @values=[]
    @branch_ques.each_with_index do |bq|
      @values << bq.options.split(";||;").index { |x| x == bq.answer }
    end
    branch_question_ids = @branch_ques.map(&:id)
    @tags = BtagsBqueRelation.where("branch_question_id in (?)",branch_question_ids).
      joins("inner join branch_tags bt on btags_bque_relations.branch_tag_id=bt.id").
      select("btags_bque_relations.id,btags_bque_relations.branch_question_id,bt.name,bt.created_at,bt.updated_at")

  end

  def create_paixu
    cell_id = params[:cell_id]
    episode_id = params[:episode_id]
    @question_packages = QuestionPackage.find_by_id(params[:id])
    @question = Question.create(types:Question::TYPES[:SORT],
      question_package_id:@question_packages.id,
      episode_id:episode_id,
      cell_id:cell_id)
  end

  def save_paixu_branch_question
    @gloab_index = params[:gloab_index]
    branch_question_id = params[:branch_question_id]
    content = params[:content].strip.gsub(/\s+/," ")
    answer = content
    if branch_question_id==""
      if BranchQuestion.create(content:content,
          question_id:params[:question_id],
          answer:answer,
          types:Question::TYPES[:SORT])
        @text=1
      else
        @text=0
      end
    else
      branch_question = BranchQuestion.find_by_id(branch_question_id)
      if branch_question.update_attributes(content:content,
          answer:answer
        )
        @text=2
      else
        @text=0
      end
    end
    @question_packages = QuestionPackage.find_by_id(params[:id])
    @question_id = params[:question_id]
    @branch_ques = BranchQuestion.where("question_id = ?",params[:question_id])
    branch_question_ids = @branch_ques.map(&:id)
    @tags = BtagsBqueRelation.where("branch_question_id in (?)",branch_question_ids).
      joins("inner join branch_tags bt on btags_bque_relations.branch_tag_id=bt.id").
      select("btags_bque_relations.id,btags_bque_relations.branch_question_id,bt.name,bt.created_at,bt.updated_at")

  end
  
  def show_the_paixu
    @index = params[:index]
    @question_packages = QuestionPackage.find_by_id(params[:id])
    @question_id = params[:question_id]
    @branch_questions = BranchQuestion.where("question_id = ?",params[:question_id])
    branch_question_ids = @branch_questions.map(&:id)
    @tags = BtagsBqueRelation.where("branch_question_id in (?)",branch_question_ids).
      joins("inner join branch_tags bt on btags_bque_relations.branch_tag_id=bt.id").
      select("btags_bque_relations.id,btags_bque_relations.branch_question_id,bt.name,bt.created_at,bt.updated_at")

  end

  def delete_paixu_branch_question
    branch_question_id = params[:branch_question_id]
    delete_branch_question branch_question_id
    @index = params[:index]
    @question_packages = QuestionPackage.find_by_id(params[:id])
    @branch_ques = BranchQuestion.where("question_id = ?",params[:question_id])
    branch_question_ids = @branch_ques.map(&:id)
    @tags = BtagsBqueRelation.where("branch_question_id in (?)",branch_question_ids).
      joins("inner join branch_tags bt on btags_bque_relations.branch_tag_id=bt.id").
      select("btags_bque_relations.id,btags_bque_relations.branch_question_id,bt.name,bt.created_at,bt.updated_at")

  end
  #删除小题
  def delete_branch_question branch_question_id
    branch_question = BranchQuestion.find_by_id(branch_question_id)
    if branch_question && branch_question.destroy
      return 1
    else
      return 0
    end
  end
  #新建题包其中第一个答题第三步之后，建题包，建答题
  def create
    question_type, new_or_refer, cell_id, episode_id, question_pack_id = params[:question_type].to_i, params[:new_or_refer], params[:cell_id], params[:episode_id], params[:question_pack_id]
    status = false
    @question_type = question_type
    QuestionPackage.transaction do
      if new_or_refer == "0"
        status, @question, @question_pack = QuestionPackage.create_new_question_pack_and_ques(question_pack_id,cell_id,episode_id,question_type, status)
        if status
          render :partial => "questions/new_branch"
        else
          render :text => "-1"  #保存失败
        end
      else
        @share_questions = ShareQuestion.share_questions(cell_id, episode_id, question_type, "desc", 1)
        if @share_questions.present?
          status, @question, @question_pack = QuestionPackage.create_new_question_pack_and_ques(question_pack_id,cell_id,episode_id,question_type, status)
          if status
            render :partial =>"questions/new_reference"
          else
            render :text => "-1" #"保存失败"
          end
        else
          render :text => "-2" #"该单元下没有题目可以引用"
        end
      end
    end
  end

  def update
    question_package = QuestionPackage.find_by_id(params[:id])
    if question_package && params[:question_package][:name]
      question_package.update_attribute(:name, params[:question_package][:name])
    end
    #redirect_to school_class_question_package_questions_path(school_class_id, question_package)
    redirect_to school_class_homeworks_path()
  end

  def render_new_question
    @question_pack_id = params[:id] if params[:id].present? && params[:id] != 'undefined'
    render :partial => "three_step"
  end

  #预览作业
  def show
    @question_pack = QuestionPackage.find_by_id(params[:id])
    @pub_que_pack = PublishQuestionPackage.find_by_question_package_id @question_pack
    redirect_to "/school_classes/#{params[:school_class_id]}/homeworks" if @question_pack.nil? 
    redirect_to "/school_classes/#{params[:school_class_id]}/question_packages/#{@question_pack.id}/new_index" if @pub_que_pack.nil?
    teacher = Teacher.find_by_id cookies[:teacher_id]
    @user = User.find_by_id teacher.user_id.to_i
    ques = []
    question = Question
    .select("id, types, name, full_text, content, questions_time, created_at, cell_id, episode_id")
    .where(["questions.question_package_id = ?", @question_pack.id])
    question.each do |q|
      p q if q.full_text.present?
    end  
    question_id = question.map{|q| q.id }.uniq
    branch_questions = BranchQuestion
    .select("content, resource_url, options, answer, question_id, id")
    .where(["question_id in (?)", question_id])
    branch_questions_id = branch_questions.map{|bq| bq.id}
    branch_questions = branch_questions.group_by {|b| b.question_id}
    @branch_tags = BtagsBqueRelation.joins("left join branch_tags bt on btags_bque_relations.branch_tag_id = bt.id")
    .select("btags_bque_relations.branch_question_id, bt.id, bt.name")
    .where(["branch_question_id in (?) and bt.id is not null",branch_questions_id])
    .group_by {|t| t.branch_question_id}
    question.each do |q|
      branch_ques = []
      if branch_questions[q.id].present?
        branch_ques = branch_questions[q.id]
      end
      ques << {:id => q.id, :name => q.name, :types => q.types, :full_text => q.full_text,
        :questions_time => q.questions_time, :created_at => q.created_at, :cell_id => q.cell_id, 
        :episode_id => q.episode_id, :content => q.content, :branch_questions => branch_ques}
    end
    @cell = Cell.find_by_id ques[0][:cell_id] if ques && ques.present? && ques[0].present?
    @episode = @cell.episodes.where("id = #{ques[0][:episode_id]}") if @cell && @cell.present?
    @episode = @episode[0] if @episode && @episode.present?
    @questions = ques
    p @questions
    p @cell
    p @episode
  end

  #删除作业
  def destroy
    question_pack = QuestionPackage.find_by_id(params[:id])
    QuestionPackage.transaction do
      #作业删除文件夹开始
      delete_question_package_folder(question_pack)
      #作业删除文件夹结束
      if question_pack.destroy
        flash[:notice] = "删除成功"
        redirect_to "/school_classes/#{school_class_id}/homeworks"
      end
    end
  end

  #设置十速挑战的时间
  def set_question_time
    Question.transaction do
      status = 1
      time_int = []
      type = ""
      begin
        question = Question.find_by_id(params[:question_id])
        hour = params[:hour]
        minute = params[:minute]
        second = params[:second]
        time = trans_time_to_int(hour=="时" ? nil : hour, minute=="分" ? nil : minute, second=="秒" ? nil : second)
        question.update_attribute("questions_time", time)
        time_int = trans_int_to_time(time)
        type = question.types==Question::TYPES[:TIME_LIMIT] ? "time_limit" : "other"
      rescue
        status = 0
      end
      render :json => {:status => status, :time_int => time_int, :type => type}
    end
  end
  #新建十速挑战
  def new_time_limit
    Question.transaction do
      cell_id = params[:cell_id].to_i
      episode_id = params[:episode_id].to_i
      question_package_id = params[:question_package_id].to_i
      @question = Question.find_by_question_package_id_and_cell_id_and_episode_id_and_types(question_package_id,
        cell_id, episode_id, Question::TYPES[:TIME_LIMIT])
      teacher = Teacher.find_by_id cookies[:teacher_id]
      @user = teacher.user
      if @question
        @branch_question = BranchQuestion.where(["question_id = ?", @question.id])
        branch_tags = BtagsBqueRelation.find_by_sql(["select bt.name, bbr.branch_question_id, bbr.branch_tag_id
        from btags_bque_relations bbr left join branch_tags bt on bbr.branch_tag_id=bt.id
        where bbr.branch_question_id in (?)", @branch_question.map(&:id)])
        @branch_tags = branch_tags.group_by{|t|t.branch_question_id}
      else
        @question = Question.create({:question_package_id => question_package_id, :cell_id => cell_id,
            :types => Question::TYPES[:TIME_LIMIT], :episode_id => episode_id})
      end
      respond_to do |f|
        f.js
      end
    end
  end
  #检查该题包下是否已经有小题
  def check_question_has_branch
    status = 0
    que_id = params[:question_id].to_i
    question = Question.find_by_id(que_id)
    time_limit_len = BranchQuestion.where(["question_id=?", question.id]).length if question
    if time_limit_len && time_limit_len > 0
      status = 1
    end
    render :json => {:status => status}
  end

  #创建十速挑战
  def create_time_limit
    BranchQuestion.transaction do
      time_limit = params[:time_limit]
      q_id = params[:question_id].to_i
      question = Question.find_by_id(q_id)
      @status = 1
      if question.nil?
        @status = 0
      else
        has_bq = BranchQuestion.where(["question_id=?", question.id])
        has_bq.each do |hb|
          BtagsBqueRelation.delete_all(["branch_question_id=?", hb.id])
          hb.destroy
        end if has_bq.any?
      end
      time_limit.each do |k, v|
        content = v["content"]
        answer = v["answer"]
        tags = v["tags"].nil? ? nil : v["tags"]
        bq = BranchQuestion.create(:content => content, :question_id => question.id, 
          :answer => answer, :options => "true;||;false", :types => Question::TYPES[:TIME_LIMIT])
        if tags
          tags.each do |t|
            BtagsBqueRelation.create(:branch_question_id => bq.id, :branch_tag_id => t.to_i)
          end
        end
      end
    end
  end

  #分享question
  def share_question
    Question.transaction do
      status = 0
      name = params[:que_name]
      que_id = params[:que_id].to_i
      question = Question.find_by_id(que_id)
      question_pack = question.question_package
      unless question.if_shared
        branch_questions = question.branch_questions
        if branch_questions.present?
          share_question = ShareQuestion.create({:user_id => current_user.id, :name => name, :types => question.types,
              :cell_id => question.cell_id, :episode_id => question.episode_id, :questions_time => question.questions_time,
              :full_text => question.full_text})
          if share_question
            question.branch_questions.each do |bq|
              new_resource_url = copy_file(share_media_path, question_pack, bq, bq.resource_url) if bq.resource_url.present? #分享的时候，拷贝音频
              new_content =  bq.content
              #选择题的话，内容里面有资源，复制资源
              if bq.types == Question::TYPES[:SELECTING] && bq.content.present? && bq.content.include?("<file>")
                content = bq.content.split("</file>")[1]
                content_file = bq.content.split("</file>")[0].split("<file>")[1]
                new_content_file = copy_file(share_media_path, question_pack, bq, content_file) if content_file.present?
                new_content = "<file>#{new_content_file}</file>#{content}"
              end
              sbq = share_question.share_branch_questions.new({:content => new_content, :resource_url => new_resource_url,
                  :options => bq.options, :answer => bq.answer, :types => bq.types})

              bq.branch_tags.each do |bt|
                sbq.branch_tags << bt
              end
              sbq.save
            end
          end
          question.update_attributes(:if_shared => true, :name => name)
          status = 0 #分享成功
        else
          status = 2 #大题下面无小题，提示
        end
      else
        status = 1 #已经分享过
      end
      render :json => {:status => status}
    end
  end

  #删除十速挑战
  def delete_question
    Question.transaction do
      question_id = params[:question_id].to_i
      status = 1
      begin
        question = Question.find_by_id(question_id)
        bqs = BranchQuestion.where(["question_id = ?", question.id]) if question
        BtagsBqueRelation.delete_all(["branch_question_id in (?)", bqs.map(&:id)]) if bqs
        bqs.each do |bq|
          bq.destroy
        end if bqs
        question.destroy if question
      rescue
        status = 0
      end
      render :json => {:status => status}
    end
  end

  #搜索标签
  def search_b_tags
    tag_name = params[:tag_name]
    teacher_id = cookies[:teacher_id]
    show_create_tag = 0
    if tag_name == ""
      b_tags = get_branch_tags(teacher_id)
    else
      name = "%#{tag_name.strip.gsub(/[%_]/){|x| '\\' + x}}%"
      b_tags = BranchTag.where(["(name like ? and teacher_id is null) or (name like ? and teacher_id=?)", name, name, teacher_id])
      tag = BranchTag.find_by_name(tag_name)
      if b_tags.blank? || tag.nil?
        show_create_tag = 1
      end
    end
    render :json => {:b_tags => b_tags, :show_create_tag => show_create_tag}
  end

  #添加标签
  def add_b_tags
    BranchTag.transaction do
      tag_name = params[:tag_name]
      teacher_id = cookies[:teacher_id]
      status = 0
      old_tag = BranchTag.find_by_name_and_teacher_id(tag_name, teacher_id)
      if old_tag
        status = 2    #表示已有同名的标签
      else
        b_tag = BranchTag.new(:name => tag_name, :teacher_id => teacher_id)
        if b_tag.save
          status = 1
        end
      end
      render :json => {:status => status, :tag_id => status==1 ? b_tag.id : 0, :tag_name => status==1 ? b_tag.name : ""}
    end
  end

  def save_branch_tag
    branch_tag_id = params[:branch_tag_id]
    branch_question_id = params[:branch_question_id]
    branch_tag = BranchTag.find_by_id(branch_tag_id)
    btagsbquetelation = BtagsBqueRelation.find_by_branch_tag_id_and_branch_question_id(branch_tag_id,branch_question_id)
    if branch_tag
      if btagsbquetelation.nil?
        @bq = BtagsBqueRelation.create(branch_question_id:branch_question_id,
          branch_tag_id:branch_tag_id)
        status = 1
      else
        status = 2
      end
    else
      status = 3
    end
    render :json => {:status => status, :tag_id => status==1 ? @bq.id : 0, :tag_name => status==1 ? branch_tag.name : ""}
  end

  def delete_branch_tag
    @type = params[:type]
    @gloab_index =params[:gloab_index]
    @q_index = params[:q_index]
    @question_packages = QuestionPackage.find_by_id(params[:id])
    branch_question_id = params[:branch_question_id]
    @branch_question = BranchQuestion.find_by_id branch_question_id
    @tags = BtagsBqueRelation.where("branch_question_id = ?",branch_question_id).
      joins("inner join branch_tags bt on btags_bque_relations.branch_tag_id=bt.id").
      select("btags_bque_relations.id,bt.name,bt.created_at,bt.updated_at")
    branch_tag = BtagsBqueRelation.find_by_id(params[:tag_id])
    if @type == "reading_or_listening"
      branch_tag = BtagsBqueRelation.find_by_branch_tag_id_and_branch_question_id(params[:tag_id], branch_question_id)
    end
    if branch_tag
      branch_tag.destroy
      @status = 1
    else
      @ststus = 0
    end
    if @type=="select" || @type=="lianxian" || @type == "reading_or_listening"
      render :json => {:status=>@status}
    end
  end


  #引用题包
  def reference_question_package
    question_package_id = params[:id]
    question_pack = QuestionPackage.find_by_id(question_package_id)
    QuestionPackage.transaction do
      begin
        if question_pack
          new_question_pack = question_pack.dup  #QuestionPackage.new(:school_class_id => school_class_id, :name => question_pack.name)
          question_pack.questions.each do |question|
            new_question = question.dup
            new_question.save
            new_question_pack.questions << new_question
            new_question_pack.school_class_id = school_class_id
            new_question_pack.save
            question.branch_questions.each do |bq|
              branch_question = new_question.branch_questions.create({:content => bq.content, :options => bq.options, :answer => bq.answer, :types => bq.types})
              new_content =  bq.content
              #选择题的话，内容里面有资源，复制资源
              if bq.types == Question::TYPES[:SELECTING] && bq.content.present? && bq.content.include?("<file>")
                content = bq.content.split("</file>")[1]
                content_file = bq.content.split("</file>")[0].split("<file>")[1]
                new_content_file = copy_file(media_path, new_question_pack, branch_question, content_file) if content_file.present?
                new_content = "<file>#{new_content_file}</file>#{content}"
              end

              new_resource_url = copy_file(media_path, new_question_pack, branch_question, bq.resource_url) if bq.resource_url.present? #引用的时候，拷贝音频
              branch_question.update_attributes(:resource_url => new_resource_url, :content => new_content)
              bq.branch_tags.each do |bt|
                branch_question.branch_tags << bt
              end
            end if question && question.branch_questions
          end if question_pack.questions
        end
        render :text => 0
      rescue Exception => e
        p e
        render :text => -1
      end
    end
  end
  
  def check_before_complete_create_package
    flag = true
    msg =""
    questionpackage = QuestionPackage.find_by_id(params[:id])

    questions = questionpackage.questions
    if questions.any?
      branch_questions = Question.find_by_sql(["select q.id question_id, q.types from questions q
        inner join branch_questions bq on bq.question_id = q.id where q.question_package_id = ?", 
          params[:id].to_i]).group_by{|i|i.question_id}
      questions.each_with_index do |question,index|
        msg1 = ""
        msg2 = ""
        if branch_questions[question.id].nil? 
          msg2 += "没有小题 "
          msg1 = "第#{index+1}题，#{Question::TYPES_NAME[question.types]}#{question.name}"
          flag = false
        end
        if question.questions_time.nil?
          msg2 +=",没有参考时间"
          msg1 ||= "第#{index+1}题，#{Question::TYPES_NAME[question.types]}#{question.name}" if msg1==""
          flag = false
        end
        if msg1!=""||msg2!=""
          msg += msg1+msg2+"<br/>"
        end
      end
    else
      msg = "当前作业包中没有任何题目，请您创建题目。"
    end
    if !flag
      flash[:success]=msg
      redirect_to new_index_school_class_question_package_path(@school_class,params[:id])
    else
      msg = "保存成功！"
      flash[:error] = msg
      redirect_to "/school_classes/#{@school_class.id}/homeworks"
    end
  end

  private
  #获取单元以及对于的课�?
  def get_cells_and_episodes
    school_class = SchoolClass.find_by_id(school_class_id) if school_class_id
    teaching_material = school_class.teaching_material if school_class
    @cells = teaching_material.cells if teaching_material
    @episodes = Episode.where(:cell_id => @cells.map(&:id)).group_by{|e| e.cell_id} if @cells
  end

  def get_count_of_wanxin question_package
    count =0
    question_package.each do |question|
      if question.types == Question::TYPES[:CLOZE]
        count +=1
      end
    end
    count
  end
end