class ApplicationController < ActionController::Base
  protect_from_forgery
  include ApplicationHelper
  include TeachersHelper
  include ApplicationHelper
  before_filter :get_teacher_infos

  def save_into_folder(question_package, branch_question, file)
    media_path_url = "/public" + media_path % question_package.id
    question_pack_path = Rails.root.to_s + media_path_url
    FileUtils.mkdir_p(question_pack_path) unless Dir.exists?(question_pack_path)
    file_extension = File.extname(file.original_filename)
    filename = "media_%d" % branch_question.id + file_extension
    File.open(question_pack_path + filename, "wb")  {|f| f.write(file.read) }
    audio_path = media_path % question_package.id + filename
    return audio_path
  end

  def delete_question_package_folder(question_pack)
    random_branch_question = nil
    question_pack.questions.each do |question|
      if question.branch_questions.any?
        random_branch_question = question.branch_questions.where("resource_url is not null")[0]  #找到某个小题的resource_url
        break
      end
    end

    #删除作业文件夹
    if random_branch_question.present? && random_branch_question.resource_url.present?
      branch_question_resource_path = "#{Rails.root}/public/" + random_branch_question.resource_url
      question_pack_dir = File.dirname(branch_question_resource_path)
      FileUtils.remove_dir question_pack_dir if Dir.exist? question_pack_dir
    end

  end
  def get_teacher_infos
   
    if current_teacher
      @schoolclasses = SchoolClass.where(:teacher_id => current_teacher.id)
      @schoolclass = SchoolClass.find(current_teacher.last_visit_class_id) if current_teacher.last_visit_class_id
      @user = User.find(current_teacher.user_id)
      @teachingmaterial = TeachingMaterial.all
    end
  end


  #分享或者引用的时候，拷贝音频
  def copy_file(media_path_url, question_pack, branch_question, source_resource_url)
    full_media_path = "/public" + media_path_url % question_pack.id
    question_pack_folder = Rails.root.to_s + full_media_path
    original_resource_url = Rails.root.to_s + "/public" + source_resource_url
    FileUtils.mkdir_p(question_pack_folder) unless Dir.exists?(question_pack_folder)
    file_extension = File.extname(original_resource_url)
    filename = "media_%d" % branch_question.id + file_extension
    if File.exists?(original_resource_url)
      FileUtils.cp original_resource_url, (question_pack_folder + filename)
      new_audio_path = media_path_url % question_pack.id + filename
    end
    new_audio_path
  end
end
