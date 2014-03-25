#encoding: utf-8
include QuestionPackagesHelper
include MethodLibsHelper
class QuestionPackagesController < ApplicationController
  before_filter :sign?, :get_unread_messes
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

  #创建听力题小题
  def save_listening
    @q_index = params[:q_index].to_i
    @b_index = params[:b_index].to_i
    types = params[:types]
    file = params[:file]
    branch_id = params[:branch_id]
    if types.present?
      @types = types.to_i
      @question = Question.find_by_id params[:question_id].to_i
      @question_id = @question.id
      if branch_id.present?
        @branch_question = BranchQuestion.find_by_id branch_id
        if @branch_question.nil?
          @status = -1
          @notice = "该小题不存在，修改失败！"
        else
          if @branch_question.update_attributes(:content => params[:content])
            @status = 0
            @notice = "小题修改成功！"  
          else
            @status = -1
            @notice = "小题修改失败！"    
          end
        end
      else
        @status = -1
        @notice = "小题创建失败！"
        content = params[:content]
        
        if !file.nil?
          @branch_question = BranchQuestion.create(:content => content, :question_id => @question_id)
          destination_dir = "question_packages/#{Time.now.strftime("%Y-%m")}/questions_package_#{@question.question_package_id}"
          rename_file_name = "media_#{@branch_question.id}"
          upload = upload_file destination_dir, rename_file_name, file
          if upload[:status] == true
            resource_url = upload[:url]
            if @branch_question.update_attributes(:resource_url=>resource_url)
              @status = 1
              @notice = "小题创建完成！"
            else
              @status = -1
              @notice = "小题创建失败！"    
            end  
          else
            @status = -1
            @notice = "小题创建失败！"
          end
        else
          @status = -1
          @notice = "文件不能为空！"
        end
      end  
    else
      @status = -1
      @notice = "该小题不存在数据错误，题型不能为空！" 
    end  
  end 
  
  #创建朗读题小题
  def save_reading
    @q_index = params[:q_index].to_i
    @b_index = params[:b_index].to_i
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
          if !file.nil?
            destination_dir = "question_packages/#{Time.now.strftime("%Y-%m")}/questions_package_#{@question.question_package_id}"
            rename_file_name = "media_#{@branch_question.id}"
            upload = upload_file destination_dir, rename_file_name, file
            if upload[:status] == true
              resource_url = upload[:url]
              if @branch_question.update_attributes(:resource_url=>resource_url)
                @status = 2
                @notice = "文件上传成功！！"
              else
                @status = -1
                @notice = "文件上传失败！"    
              end  
            else
              @status = -1
              @notice = "小题创建失败！"
            end
          else
            if params[:content].present?
              if @branch_question.update_attributes(:content => params[:content] )
                @status = 0
                @notice = "小题修改成功！"  
              else
                @status = -1
                @notice = "小题修改失败！" 
              end
            else
                
            end  
          end

          
        end
      else
        @status = -1
        @notice = "小题创建失败！"
        content = params[:content]
        @branch_question = BranchQuestion.create(:content => content, :question_id => @question_id)
        unless @branch_question.nil? 
          @status = 1
          @notice = "小题创建完成！"
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
    @question_pack = QuestionPackage.find_by_id(params[:id])
    @question_type = Question::TYPES_NAME
    @cells = Cell.where("teaching_material_id = ?",@school_class.teaching_material_id )
    @questions = Question.where("question_package_id=#{@question_pack.id}")
    get_has_time_limit(@question_pack.id)
    #@reading_and_listening_branch  = Question.get_has_reading_and_listening_branch(@questions)
    #引用url
    @reference_part_url = "/school_classes/#{@school_class.id}/question_packages/#{@question_pack.id}/share_questions/list_questions_by_type"
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
    episode_id = params[:episode_id]
    @question_packages = QuestionPackage.find_by_id(params[:id])
    @question = Question.create(types:Question::TYPES[:CLOZE],question_package_id:@question_packages.id,episode_id:episode_id)
    @questions = []
    @questions << @question
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
  end

  def save_wanxin_content
    content = params[:content]
    @question = Question.find_by_id(params[:id])
    if @question.update_attribute(:content, content)
      render text:1
    else
      render text:0
    end
  end

  def save_wanxin_branch_question
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
      if BranchQuestion.create(content:params[:title],
          question_id:params[:question_id],
          options:options,
          answer:answer)
        render text:1
      else
        render text:0
      end
    else
      branch_question = BranchQuestion.find_by_id(branch_question_id)
      if branch_question.update_attributes(content:params[:title],
          options:options,
          answer:answer
        )
        render text:1
      else
        render text:0
      end
    end
  end
  def delete_wanxin_branch_question
    branch_question_id = params[:branch_question_id]
    delete_branch_question branch_question_id
    @index = params[:index]
    @question_packages = QuestionPackage.find_by_id(params[:id])
    @branch_questions = BranchQuestion.where("question_id = ?",params[:question_id])
    @options = @branch_questions.map{|d| d.options.split(";||;")}
    @values=[]
    @branch_questions.each_with_index do |bq|
      @values << bq.options.split(";||;").index { |x| x == bq.answer }
    end
  end

  def create_paixu
    episode_id = params[:episode_id]
    @question_packages = QuestionPackage.find_by_id(params[:id])
    @question = Question.create(types:Question::TYPES[:SORT],question_package_id:@question_packages.id,episode_id:episode_id)
  end

  def save_paixu_branch_question
    branch_question_id = params[:branch_question_id]
    content = params[:content].strip.gsub(/\s+/," ")
    answer = content
    if branch_question_id==""
      if BranchQuestion.create(content:content,
          question_id:params[:question_id],
          answer:answer)
        render text:1
      else
        render text:0
      end
    else
      branch_question = BranchQuestion.find_by_id(branch_question_id)
      if branch_question.update_attributes(content:content,
          answer:answer
        )
        render text:3
      else
        render text:0
      end
    end
  end
  def show_the_paixu
    @index = params[:index]
    @question_packages = QuestionPackage.find_by_id(params[:id])
    @question_id = params[:question_id]
    @branch_questions = BranchQuestion.where("question_id = ?",params[:question_id])
  end

  def delete_paixu_branch_question
    branch_question_id = params[:branch_question_id]
    delete_branch_question branch_question_id
    @index = params[:index]
    @question_packages = QuestionPackage.find_by_id(params[:id])
    @branch_questions = BranchQuestion.where("question_id = ?",params[:question_id])
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
    teacher = Teacher.find_by_id cookies[:teacher_id]
    @user = User.find_by_id teacher.user_id.to_i
    @origin_questions = nil
    question_type = QuestionPackage.get_one_package_questions @question_pack.id
    @question_type = question_type.map(&:types).uniq.sort if question_type.present? || []
    p @question_type
    ques = []
    question = Question
    .select("id, types, name, full_text, content, questions_time, created_at")
    .where(["questions.question_package_id = ?", @question_pack.id])
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
        :questions_time => q.questions_time, :created_at => q.created_at,
        :content => q.content, :branch_questions => branch_ques}
    end
    @questions = ques.group_by {|q| q[:types]}
    p @questions
    #p @branch_tags
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

  #新建十速挑战
  def new_time_limit
    #    cell_id = params[:cell_id].to_i
    #    episode_id = params[:episode_id].to_i
    question_package_id = params[:question_package_id].to_i
    get_has_time_limit(question_package_id)
    respond_to do |f|
      f.js
    end
  end

  #检查该题包下是否已经有十速挑战
  def check_time_limit
    status = 1
    q_p_id = params[:q_p_id].to_i
    #    cell_id = params[:cell_id].to_i
    #    episode_id = params[:episode_id].to_i
    question = Question.find_by_types_and_question_package_id(Question::TYPES[:TIME_LIMIT], q_p_id)
    time_limit_len = BranchQuestion.where(["question_id=?", question.id]).length if question
    if time_limit_len && time_limit_len > 0
      status = 0
    end
    render :json => {:status => status}
  end

  #创建十速挑战
  def create_time_limit
    BranchQuestion.transaction do
      time_limit = params[:time_limit]
      q_p_id = params[:question_package_id].to_i
      #      cell_id = params[:cell_id].to_i
      #      episode_id = params[:episode_id].to_i
      time = 0
      hour = params[:create_time_limit_hour]
      minute = params[:create_time_limit_minute]
      second = params[:create_time_limit_second]
      unless hour.nil? || hour.strip=="" || hour.eql?("时") || hour.to_i==0
        time += hour.to_i * 360
      end
      unless minute.nil? || minute.strip=="" || minute.eql?("分") || minute.to_i==0
        time += minute.to_i * 60
      end
      unless second.nil? || second.strip=="" || second.eql?("秒") || second.to_i==0
        time += minute.to_i
      end

      @question = Question.find_by_types_and_question_package_id(Question::TYPES[:TIME_LIMIT], q_p_id)
      if @question.nil?
        @question = Question.new(:types => Question::TYPES[:TIME_LIMIT],
          :questions_time => time, :question_package_id => q_p_id)
        @question.save
      else
        @question.update_attribute("questions_time", time)
        has_bq = BranchQuestion.where(["question_id=?", @question.id])
        has_bq.each do |hb|
          BtagsBqueRelation.delete_all(["branch_question_id=?", hb.id])
          hb.destroy
        end if has_bq.any?
      end
      time_limit.each do |k, v|
        content = v["content"]
        answer = v["answer"]
        tags = v["tags"].nil? ? nil : v["tags"]
        bq = BranchQuestion.create(:content => content, :question_id => @question.id, :answer => answer)
        if tags
          tags.each do |t|
            BtagsBqueRelation.create(:branch_question_id => bq.id, :branch_tag_id => t.to_i)
          end
        end
      end
    end
  end

  #分享十速挑战
  def share_time_limit
    Question.transaction do
      status = 0
      name = params[:time_limit_name]
      #      cell_id = params[:cell_id].to_i
      #      episode_id = params[:episode_id].to_i
      q_p_id = params[:q_p_id].to_i
      question = Question.find_by_types_and_question_package_id(Question::TYPES[:TIME_LIMIT],q_p_id)
      if question && question.update_attribute("name", name)
        status = 1
      end
      render :json => {:status => status}
    end
  end

  #删除十速挑战
  def delete_time_limit
    Question.transaction do
      q_p_id = params[:q_p_id].to_i
      #      cell_id = params[:cell_id].to_i
      #      episode_id = params[:episode_id].to_i
      status = 1
      question = Question.find_by_types_and_question_package_id(Question::TYPES[:TIME_LIMIT], q_p_id)
      begin
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
    if tag_name == ""
      b_tags = get_branch_tags(teacher_id)
    else
      name = "%#{tag_name.strip.gsub(/[%_]/){|x| '\\' + x}}%"
      b_tags = BranchTag.where(["(name like ? and teacher_id is null) or (name like ? and teacher_id=?)", name, name, teacher_id])
    end
    render :json => {:b_tags => b_tags}
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
    if branch_tag && BtagsBqueRelations.create(branch_question_id:branch_question_id,
        branch_tag_id:branch_tag_id)
      status = 1
    else
      status = 2
    end
    render :json => {:status => status, :tag_id => status==1 ? branch_tag.id : 0, :tag_name => status==1 ? branch_tag.name : ""}
  end

  private
  #获取单元以及对于的课�?
  def get_cells_and_episodes
    school_class = SchoolClass.find_by_id(school_class_id) if school_class_id
    teaching_material = school_class.teaching_material if school_class
    @cells = teaching_material.cells if teaching_material
    @episodes = Episode.where(:cell_id => @cells.map(&:id)).group_by{|e| e.cell_id} if @cells
  end

end