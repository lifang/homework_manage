#encoding: utf-8
class StudentAnswerRecord < ActiveRecord::Base
  attr_protected :authentications
  STATUS = {:NEW => 0, :DEALING => 1, :FINISH => 2}
  STATUS_NAME = {0 => "新任务", 1 => "进行中", 2 => "完成"}

  def self.get_daily_tasks school_class, student_id
    dealing_tasks = nil
    unfinish_tasks = nil
    return_into = {:dealing_tasks => dealing_tasks, :unfinish_tasks => unfinish_tasks}
  end
end
