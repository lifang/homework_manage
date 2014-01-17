#encoding: utf-8
class StudentAnswerRecord < ActiveRecord::Base
  attr_protected :authentications
  belongs_to :student
  STATUS = {:DEALING => 0, :FINISH => 1}
  STATUS_NAME = {0 => "进行中", 1 => "完成"}

  def self.get_daily_tasks school_class_id, student_id
    tasks = []
    worked_tasks_sql = "select p.id, q.name,s.status,p.start_time,p.end_time, p.question_packages_url,
      s.listening_answer_count, s.reading_answer_count, p.listening_count, p.reading_count FROM
      student_answer_records s left join publish_question_packages p on
      s.publish_question_package_id = p.id left join question_packages q on
      p.question_package_id = q.id where s.school_class_id = #{school_class_id}
      and s.student_id = #{student_id} and TIMESTAMPDIFF(SECOND,now(),p.end_time) > 0"
    worked_tasks= StudentAnswerRecord.find_by_sql worked_tasks_sql  #处理过的任务信息（包含进行中的和已完成的）
    worked_tasks.each_with_index do |task,index|
      tasks << {:id => task.id, :name => task.name, :start_time => task.start_time,
                :end_time => task.end_time, :question_packages_url => task.question_packages_url,
                :listening_schedule => "#{task.listening_answer_count}/#{task.listening_count}",
                :reading_schedule => "#{task.reading_answer_count}/#{task.reading_count}"
                }
    end
    worked_ids = "("
    worked_tasks.each_with_index do |task,index|
        worked_ids += "," if index > 0
        worked_ids += "#{task.id}"
    end
    worked_ids += ")"
    condition_sql = "and p.id not in #{worked_ids}"
    unfinish_tasks_sql = "select p.id, q.name,p.start_time,p.end_time, p.question_packages_url,
                    p.listening_count, p.reading_count  FROM publish_question_packages p
                    left join question_packages q on p.question_package_id = q.id where
                     TIMESTAMPDIFF(SECOND,now(),p.end_time) > 0"
    unfinish_tasks_sql += condition_sql if worked_ids.to_s.match("()") == false
    unfinish_tasks = PublishQuestionPackage.find_by_sql unfinish_tasks_sql
    unfinish_tasks.each do |task|
      tasks << {:id => task.id, :name => task.name, :start_time => task.start_time,
               :end_time => task.end_time, :question_packages_url => task.question_packages_url,
               :listening_schedule => "#{0}/#{task.listening_count}",
               :reading_schedule => "#{0}/#{task.reading_count}"
               }
    end
    tasks
  end
end
