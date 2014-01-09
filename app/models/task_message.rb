#encoding: utf-8
class TaskMessage < ActiveRecord::Base
  attr_protected :authentications
  belongs_to :school_class
  STATUS = {:YES => 0, :NO => 1}
  STATUS_NAME = {0 => "正常", 1 => "失效"}

  def self.get_task_messages school_class_id
    task_messgages = TaskMessage.find_by_sql("select t.id, t.content, p.end_time from task_messages t join
                      publish_question_packages p on t.publish_question_package_id = p.id
                      where t.school_class_id = #{school_class_id} and t.status = #{TaskMessage::STATUS[:YES]}
                      and TIMESTAMPDIFF(SECOND,now(),t.period_of_validity) > 0")
  end
end
