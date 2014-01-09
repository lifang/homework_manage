#encoding: utf-8
class StudentAnswerRecord < ActiveRecord::Base
  attr_protected :authentications
  STATUS = {:DEALING => 0, :FINISH => 1}
  STATUS_NAME = {0 => "进行中", 1 => "完成"}

  def self.get_daily_tasks school_class_id, student_id

    worked_tasks_sql = "select p.id, q.name,s.status,p.end_time, p.question_packages_url FROM student_answer_records s
      left join publish_question_packages p on s.publish_question_package_id = p.id left join
      question_packages q on p.question_package_id = q.id where s.school_class_id = #{school_class_id}
      and s.student_id = #{student_id} and TIMESTAMPDIFF(SECOND,now(),p.end_time) > 0"
    worked_tasks= StudentAnswerRecord.find_by_sql worked_tasks_sql  #处理过的任务信息（包含进行中的和已完成的）
    dealing_tasks = []
    finish_tasks = []
    unfinish_tasks = []
    worked_tasks.each do |task|
      t = {:id => task.id, :name => task.name, :end_time => task.end_time,
           :question_packages_url => task.question_packages_url}
      dealing_tasks << t if task.status == StudentAnswerRecord::STATUS[:DEALING]
      finish_tasks << t if task.status == StudentAnswerRecord::STATUS[:FINISH]
    end
    #unfinish_tasks_sql = "select p.id, q.name,p.end_time, p.question_packages_url FROM "
    #unfinish_tasks = PublishQuestionPackage.find_by_sql unfinish_tasks_sql
    return_into = {:dealing_tasks => dealing_tasks, :unfinish_tasks => unfinish_tasks,
                  :finish_tasks => finish_tasks}
  end
end
