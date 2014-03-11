#encoding: utf-8
class StatisticsController < ApplicationController
  #完成率统计
  def index
    school_class_id = params[:school_class_id]
    school_class = SchoolClass.find_by_id school_class_id
    today = Time.now.strftime("%Y-%m-%d")
    today_tasks = PublishQuestionPackage.joins('left join tags t on publish_question_packages.tag_id = t.id')
      .select("publish_question_packages.id, publish_question_packages.tag_id,
              publish_question_packages.question_package_id, t.name")
      .where("publish_question_packages.created_at >= '#{today} 00:00:00'
             and publish_question_packages.created_at <= '#{today} 23:59:59'")
      .order("publish_question_packages.created_at desc")
    today_tasks.sort_by! {|t| t.name.to_s}
    if today_tasks.length > 0
      tags_id = today_tasks.map(&:tag_id)
      today_tasks = today_tasks.group_by {|t| t.tag_id}
      p today_tasks
      tags = Tag.where("id in (?)", tags_id)
      tags.sort_by! {|t| t.name}
      all_tags = []
      tags.each do |e|
        all_tags << {:tag_name => e.name, :tag_id => e.id, :pub_id => today_tasks[e.id][0].id}
      end
      all_tags << {:tag_name => "全班", :tag_id => nil, :pub_id => today_tasks[nil][0].id}  if tags_id.include?(nil)
      current_task = today_tasks[tags[0].id.to_i][0]
      p current_task
      question_types = QuestionPackage.get_one_package_questions current_task.question_package_id
      students_id = SchoolClassStudentRalastion.where(["school_class_id = ? and tag_id = ?",
                      school_class.id, tags[0].id]).map(&:id)
      p students_id
      student_answer_records = StudentAnswerRecord.joins("left join students s on
            student_answer_records.student_id = s.id")
          .joins("left join users u on s.user_id = u.id")
          .select("student_answer_records.id, student_answer_records.publish_question_package_id,
              student_answer_records.average_correct_rate, student_answer_records.average_complete_rate,
              student_answer_records.student_id, u.name, u.avatar_url")
          .where("publish_question_package_id = ?",current_task.id)
      student_answer_records_id = student_answer_records.map(&:id)
      record_details = RecordDetail
          .select("question_types, used_time, is_complete, student_answer_record_id")
          .where("student_answer_record_id in (?) and is_complete = ?",student_answer_records_id,
                RecordDetail::STATUS[:FINISH])
      answer_details = record_details.map{|r|  {:id => r.student_answer_record_id,
                        :types => r.question_types, :used_time => r.used_time } }
                      .group_by {|r| r[:id] }
      complete_rate = []
      student_answer_records.each do |s|
        complete_rate << {:id => s.id, :pub_id => s.publish_question_package_id,
                  :average_correct_rate => s.average_correct_rate,
                  :average_complete_rate => s.average_complete_rate,
                  :student_id => s.student_id, :name => s.name, :avatar_url => s.avatar_url,
                  :answer_details => answer_details[s.id]}
      end

      average_correct_rate = student_answer_records.sum {|s| s.average_correct_rate}/
          student_answer_records.length
      average_complete_rate = student_answer_records.sum {|s| s.average_complete_rate}/
          student_answer_records.length
    end

    render :json => {:average_correct_rate => average_correct_rate,
                     :average_complete_rate =>average_complete_rate,
                     :all_tags => all_tags, :complete_rate => complete_rate}
  end

  #正确率统计
  def correct_rate

  end
end
