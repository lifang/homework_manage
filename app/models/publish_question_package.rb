#encoding: utf-8
class PublishQuestionPackage < ActiveRecord::Base
  attr_protected :authentications
  belongs_to :teacher
  belongs_to :question_package
  has_one :task_message
  STATUS = {:NEW => 0, :FINISH => 1,:EXPIRED => 2}
  STATUS_NAME = {0 => "新任务", 1 => "完成",2 => '过期'}
  PER_PAGE = 10

  #获取当日或历史任务
  def self.get_tasks school_class_id, student_id, order_name=nil, date=nil
    my_tag_ids = Tag.get_my_tag_ids school_class_id, student_id
    tags = "#{my_tag_ids}".gsub(/\[/,"(").gsub(/\]/,")") if my_tag_ids && my_tag_ids.length != 0
    tasks_sql = "select p.id, q.name,p.question_package_id que_pack_id,p.start_time,p.end_time,
            p.question_packages_url FROM publish_question_packages p left join question_packages q
            on p.question_package_id = q.id where p.school_class_id = #{school_class_id}"
    date_now = Time.now.strftime('%Y-%m-%d')
    if !order_name.nil? && order_name == "first"
      tasks_sql += " and p.status = #{PublishQuestionPackage::STATUS[:NEW]} and
        p.start_time >= '#{date_now} 00:00:00'
        and p.start_time <= '#{date_now} 23:59:59'"
    end
    if !date.nil?
      tasks_sql += " and p.start_time >= '#{date} 00:00:00'
        and p.start_time <= '#{date} 23:59:59'"
    end
    tasks_sql += " and (p.tag_id is null or p.tag_id in #{tags})"  if my_tag_ids && my_tag_ids.length != 0
    tasks_sql += " order by p.start_time desc"
    tasks_sql += " limit 1" if !order_name.nil? && order_name == "first"
    pub_tasks = PublishQuestionPackage.find_by_sql tasks_sql
    pub_tasks = pub_tasks[1..pub_tasks.length-1] if order_name.nil? && date.nil?
    pub_ids = pub_tasks.map(&:id)
    que_pack_ids = pub_tasks.map(&:que_pack_id)
    student_answer_records = StudentAnswerRecord.get_student_answer_status school_class_id,student_id, pub_ids
    student_answer_records = student_answer_records.group_by{ |sar| sar.pub_id }
    que_packs_types =  QuestionPackage.get_all_packs_que_types school_class_id, que_pack_ids
    que_packs_types = que_packs_types.group_by{ |q| q.id }
    tasks = []
    pub_tasks.each_with_index do |task|
      question_types = []
      finish_types = []
      if !que_packs_types[task.que_pack_id].nil?
        question_types = que_packs_types[task.que_pack_id].map(&:types)
      end
      if !student_answer_records[task.id].nil?
        finish_types = student_answer_records[task.id].map(&:types)
      end
      tasks << {:id => task.id, :name => task.name, :start_time => task.start_time,
                :question_types => question_types, :finish_types => finish_types,
                :end_time => task.end_time, :question_packages_url => task.question_packages_url
      }
    end
    tasks
  end
end
