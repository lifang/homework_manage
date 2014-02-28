class ApplicationController < ActionController::Base
  protect_from_forgery
  include ApplicationHelper
  include TeachersHelper

  def save_into_folder(question_package, branch_question, file)
    media_path = "/public" + MEDIA_PATH % question_package.id
    question_pack_path = Rails.root.to_s + media_path
    FileUtils.mkdir_p(question_pack_path) unless Dir.exists?(question_pack_path)
    file_extension = File.extname(file.original_filename)
    filename = "media_%d" % branch_question.id + file_extension
    File.open(question_pack_path + filename, "wb")  {|f| f.write(file.read) }
    audio_path = MEDIA_PATH % question_package.id + filename
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
end
