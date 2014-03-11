#encoding: utf-8
class StatisticsController < ApplicationController
  #完成率统计
  def index
    school_class_id = params[:school_class_id]
    school_class = SchoolClass.find_by_id school_class_id
    today = Time.now.strftime("%Y-%m-%d")
    p "#{today}"
    sql_str = "select * from publish_question_packages p
       where created_at >= '#{today} 00:00:00' and created_at <= '#{today} 23:59:59'
       order by created_at desc"
    publish_question_packages = PublishQuestionPackage.find_by_sql sql_str
    if publish_question_packages.length > 0
      publish_question_package = publish_question_packages[0]
      sql = "select avg(s.average_correct_rate), avg(s.average_complete_rate) from student_answer_records s where s.publish_question_package_id =
        #{publish_question_package.id}"
      student_answer_records = StudentAnswerRecord.find_by_sql sql
    end
    p publish_question_packages
  end

  #正确率统计
  def correct_rate

  end
end
