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
end
