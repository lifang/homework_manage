#encoding:utf-8
module HomeworksHelper
  def is_shared(question)
    question.if_shared ? "share_icon_ed" : "share_icon"
  end
end
