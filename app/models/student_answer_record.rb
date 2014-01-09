#encoding: utf-8
class StudentAnswerRecord < ActiveRecord::Base
  attr_protected :authentications
  STATUS = {:DEALING => 0, :FINISH => 1}
  STATUS_NAME = {0 => "进行中", 1 => "完成"}

  def self.get_daily_tasks school_class, student_id
    #dealing_tasks_sql_str = "select "
    #dealing_tasks = Student.find_by_sql dealing_tasks_sql_str
    dealing_tasks = nil
    unfinish_tasks = nil
    return_into = {:dealing_tasks => dealing_tasks, :unfinish_tasks => unfinish_tasks}
  end
end
