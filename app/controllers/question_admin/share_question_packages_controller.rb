#encoding: utf-8
class QuestionAdmin::ShareQuestionPackagesController < ApplicationController
  skip_before_filter :get_teacher_infos,:get_unread_messes, :only => [:index, :new, :edit]
  before_filter :check_if_questionadmin, :only => [:index, :new, :edit]
  layout "/question_admin/question_manages"
  
  def index
    @share_question_packages = current_teacher.share_question_packages.order("created_at desc").paginate(:page => params[:page] || 1, :per_page => PublishQuestionPackage::PER_PAGE)
    @question_types = ShareQuestionPackage.get_each_type(@share_question_packages)
  end

  def new
    @share_question_package = current_teacher.share_question_packages.create
    redirect_to "/question_admin/share_question_packages/#{@share_question_package.id}/edit"
  end

  def edit
    @school_class_id = -1
    @share_question_package = ShareQuestionPackage.find_by_id params[:id]
    @question_package_id = @share_question_package.id
    @questions = @share_question_package.share_questions
    share_branch_questions = ShareBranchQuestion.where(["share_question_id in (?)", @questions.map(&:id)])
    @branch_questions = share_branch_questions.group_by{|bq|bq.share_question_id}

    #tags
    branch_tags = ShareBranchQuestion.bunch_branch_tags(share_branch_questions.map(&:id))
    h_branch_tags = branch_tags.group_by{|t|t.share_question_id} #{bqid
    hash = {}
    h_branch_tags.each do |k, v|
      second_tags = v.group_by{|t|t.share_branch_question_id}
      hash[k] = second_tags
    end
    @branch_tags = hash
    
    if @share_question_package.cell_id.present?
      @cell_id = @share_question_package.cell_id
      @cell_name = @share_question_package.cell.name
    end
    if @share_question_package.episode_id.present?
      @episode_id = @share_question_package.episode_id
      @episode_name = @share_question_package.episode.name
    end
    @b_tags = get_branch_tags(cookies[:teacher_id])
    @cells = Cell.where("teaching_material_id = ?",current_teacher.teaching_material_id )
  end

  def check_has_share_package
    cell_id = params[:cell_id]
    episode_id = params[:episode_id]
    question_pack_id = params[:package_id].to_i
    share_question_package = ShareQuestionPackage.find_by_cell_id_and_episode_id(cell_id, episode_id)
    if share_question_package
      if share_question_package.id == question_pack_id && share_question_package.created_by == current_teacher.id
         status = 0
      else
        status = 1
      end
    else
      status = 0
    end
    render :text => status
  end

  def check_complete
    flag = true
    msg =""
    share_question_package = ShareQuestionPackage.find_by_id(params[:id])

    share_questions = share_question_package.share_questions
    if share_questions.any?
      share_branch_questions = ShareQuestion.find_by_sql(["select q.id question_id, q.types from share_questions q
        inner join share_branch_questions bq on bq.share_question_id = q.id where q.share_question_package_id = ?",
          params[:id].to_i]).group_by{|i|i.question_id}
      msg_arr1 = []
      msg_arr2 = []
      share_questions.each_with_index do |question,index|
        if share_branch_questions[question.id].nil?
          msg_arr1 << "第#{index+1}题，#{Question::TYPES_NAME[question.types]}#{question.name} 没有小题"
          flag = false
        end
        if question.questions_time.nil?
          msg_arr2 << "第#{index+1}题，#{Question::TYPES_NAME[question.types]}#{question.name} 没有参考时间"
          flag = false
        end
      end
      msg1 = msg_arr1.join("<br/>")
      msg2 = msg_arr2.join("<br/>")
      msg = msg1 + "<br/>" + msg2
    else
      msg = "当前作业包中没有任何题目，请您创建题目。"
    end
    if !flag
      flash[:success]=msg
      redirect_to "/question_admin/share_question_packages/#{params[:id]}/edit"
    else
      msg = "保存成功！"
      flash[:error] = msg
      redirect_to "/question_admin/share_question_packages"
    end
  end

  #预览作业
  def show
    @question_pack = ShareQuestionPackage.find_by_id(params[:id])
    if @question_pack.nil?
      flash[:notice] = "题包不存在"
      redirect_to "/question_admin/share_question_packages"
    else
      teacher = Teacher.find_by_id cookies[:teacher_id]
      @user = User.find_by_id teacher.user_id.to_i
      ques = []
      share_questions = @question_pack.share_questions
      share_question_ids = share_questions.map{|q| q.id }.uniq
      branch_questions = ShareBranchQuestion
      .select("content, resource_url, options, answer, share_question_id, id")
      .where(["share_question_id in (?)", share_question_ids])
      branch_questions_id = branch_questions.map{|bq| bq.id}
      branch_questions = branch_questions.group_by {|b| b.share_question_id}
      @branch_tags = ShareBranchQuestion.bunch_branch_tags(branch_questions_id).group_by {|t| t.share_branch_question_id}
      share_questions.each do |q|
        branch_ques = []
        if branch_questions[q.id].present?
          branch_ques = branch_questions[q.id]
        end
        ques << {:id => q.id, :name => q.name, :types => q.types, :full_text => q.full_text,
          :questions_time => q.questions_time, :created_at => q.created_at, :cell_id => q.cell_id,
          :episode_id => q.episode_id, :branch_questions => branch_ques}
      end
      @cell = Cell.find_by_id ques[0][:cell_id] if ques && ques.present? && ques[0].present?
      @episode = @cell.episodes.where("id = #{ques[0][:episode_id]}") if @cell && @cell.present?
      @episode = @episode[0] if @episode && @episode.present?
      @questions = ques
    end
    render :layout => "application"
  end

  def destroy
    QuestionPackage.transaction do
      share_question_pack = ShareQuestionPackage.find_by_id(params[:id])
      #作业删除文件夹开始
      delete_qa_question_package_folder(share_question_pack)
      #作业删除文件夹结束
      if share_question_pack.destroy
        flash[:notice] = "删除成功"
        redirect_to "/question_admin/share_question_packages"
      end
    end
  end

  def delete_qa_question_package_folder(share_question_pack)
    random_branch_question = nil
    share_question_pack.share_questions.each do |share_question|
      if share_question.share_branch_questions.any?
        random_branch_question = share_question.share_branch_questions.where("resource_url is not null or content like '%<file>%'")[0]  #找到某个小题的resource_url
        break if random_branch_question
      end
    end
    #删除作业文件夹
    if random_branch_question.present?
      if random_branch_question.resource_url.present?
        branch_question_resource_path =  random_branch_question.resource_url
      elsif random_branch_question.content.include?("<file>")
        branch_question_resource_path =  /<file>(.*)<\/file>/.match(random_branch_question.content).to_a[1]
      end
      full_branch_question_resource_path = "#{Rails.root}/public/" + branch_question_resource_path
      question_pack_dir = File.dirname(full_branch_question_resource_path)
      FileUtils.remove_dir question_pack_dir if Dir.exist? question_pack_dir
    end
  end
end