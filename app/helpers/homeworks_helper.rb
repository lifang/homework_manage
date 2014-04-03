#encoding:utf-8
module HomeworksHelper
  def is_shared(question)
    (question.if_shared || question.if_from_reference) ? "share_icon_ed" : "share_icon"
  end
end
