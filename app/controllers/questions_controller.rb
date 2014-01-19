class QuestionsController < ApplicationController
  

  #第四步，保存新建的一个大题
  def create
    @question_pack = QuestionPackage.find_by_id(params[:question_package_id])
    @question = @question_pack.questions.create(params[:question])
    content_arr = params[:branch_content]
    resource_url_arr = params[:branch_url]
    
    flag = true
    BranchQuestion.transaction do
      content_arr.each_with_index do |content, index|
        bq = @question.branch_questions.create(:content => content)
        resource_url_paths = save_into_folder(@question_pack, bq, resource_url_arr[index])if resource_url_arr[index]
        bq.update_attributes({:resource_url => resource_url_paths[index]} ) if resource_url_paths[index]
        flag = false unless bq
      end
      if flag
        @edit_path = edit_question_package_question_path(@question_pack, @question)
        render :success
      else
        render :failed
      end
    end
  end

  def edit
    @question_pack = QuestionPackage.find_by_id(params[:question_package_id])
    @question = Question.find_by_id(params[:id])
    @branch_questions = @question.branch_questions
  end

  def save_into_folder(question_package, branch_question, file)
    media_path = "/public" + MEDIA_PATH % question_package.id
    file_path = []
    question_pack_path = Rails.root.to_s + media_path
    FileUtils.mkdir_p(question_pack_path) unless Dir.exists?(question_pack_path)
    file_extension = File.extname(file.original_filename)
    filename = "media_%d" % branch_question.id + file_extension
    File.open(question_pack_path + filename, "wb")  {|f| f.write(file.read) }
    audio_path = MEDIA_PATH % question_package.id + filename
    file_path << audio_path
    return file_path
  end

end