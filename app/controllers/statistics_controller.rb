#encoding: utf-8
include StatisticsHelper
class StatisticsController < ApplicationController
  layout "tapplication"
  #完成率及正确率统计
  def index
    school_class_id = params[:school_class_id]
    school_class = SchoolClass.find_by_id school_class_id
    @today_date = Time.now.strftime("%Y-%m-%d")
    info = PublishQuestionPackage.get_homework_statistics @today_date, school_class
    @all_tags = info[:all_tags]
    @current_task = info[:current_task]
    @current_date =  @current_task.nil? ? @today_date : @current_task.created_at.strftime("%Y-%m-%d")
    @question_types = info[:question_types]
    @details = info[:details]
    @average_correct_rate = info[:average_correct_rate]
    @average_complete_rate = info[:average_complete_rate]
  end

  #切换日期
  def checkout_by_date
    school_class_id = params[:school_class_id]
    date = params[:date]
    school_class = SchoolClass.find_by_id school_class_id
    @today_date = Time.now.strftime("%Y-%m-%d")
    info = PublishQuestionPackage.get_homework_statistics date, school_class
    @all_tags = info[:all_tags]
    @current_task = info[:current_task]
    @current_date = date
    @question_types = info[:question_types]
    @details = info[:details]
    @average_correct_rate = info[:average_correct_rate]
    @average_complete_rate = info[:average_complete_rate]
    p @details
    p @question_types
  end

  #根据标签显示完成率及正确率统计
  def show_tag_task
    date = params[:date]
    pub_id = params[:pub_id].to_i
    tag_id = params[:tag_id]
    @current_task = PublishQuestionPackage.find_by_id pub_id
    info = PublishQuestionPackage.get_record_details(@current_task,tag_id, @current_task.school_class_id)
    @question_types = info[:question_types]
    @details = info[:details]
    @average_complete_rate = info[:average_complete_rate]
    @average_correct_rate = info[:average_correct_rate]
  end

  #获取该任务下题型统计信息
  def show_question_statistics
    pub_id = params[:pub_id].to_i
    school_class_id = params[:school_class_id]
    publish_question_package = PublishQuestionPackage.find_by_id pub_id
    tag_id = publish_question_package.tag_id unless publish_question_package.nil?
    info = PublishQuestionPackage.get_quetion_types_statistics(publish_question_package,
          tag_id, school_class_id)
    @question_types = info[:question_types]
    @questions = info[:questions]
    use_times = info[:use_times]
    @type_average_correct_rate = info[:type_average_correct_rate]
    use_times = use_times.group_by {|q| q[:types]} if use_times.present?
    tmp = []
    use_times.each do |k,e|
      use_times = 0
      times = e.map{|q| q[:use_time]}
      correct_rt = @questions[k].map do |q|
         q[:average_correct_rate] if q[:average_correct_rate].present? && q[:average_correct_rate] >= 0
      end
      correct_rt = (eval correct_rt.join('+'))/correct_rt.length if correct_rt.present?
      use_times = (eval times.join('+'))/times.length if times.present?
      tmp << {:types => k, :use_time => use_times, :correct_rate => correct_rt}
    end
    @use_times = tmp.group_by{|q| q[:types]}
    p @use_times
    p @questions
    p @type_average_correct_rate = @type_average_correct_rate.group_by{|q| q[:types]} if @type_average_correct_rate.present?
  end

  #正确率列表——显示某一类型（学生做错的题目）原题
  def show_incorrect_questions
    types = params[:question_types].to_i
    student_answer_record_id = params[:student_answer_record_id]
    student_answer_record = StudentAnswerRecord.find_by_id student_answer_record_id
    p student_answer_record
    record_details = RecordDetail.find_by_student_answer_record_id student_answer_record.id unless student_answer_record.nil?
    @status = false
    @questions = nil
    @notice = "该学生的答题记录不存在！"
    if !student_answer_record.nil? && !student_answer_record.answer_file_url.nil?
      if record_details.nil?
        @notice = "该学生的#{Question::TYPES_NAME[:question_types]}答题记录为空！"
      else
        anwser_file_url = "#{Rails.root}/public#{student_answer_record.answer_file_url}"
        p anwser_file_url
        if File.exist? anwser_file_url
          answer_json = ""
          begin
            File.open(anwser_file_url) do |file|
              file.each do |line|
                answer_json += line.to_s
              end
            end
            answer_records = ActiveSupport::JSON.decode(answer_json)
          rescue
            @notice = "答题记录读取失败！"
          end
            wrong_ids = read_answer_hash answer_records,types
            if wrong_ids.present?
              p wrong_ids
              branch_que = BranchQuestion
                .joins("left join questions q on branch_questions.question_id = q.id")
                .select("distinct q.id")
                .where(["branch_questions.id in (?) and q.id is not null",wrong_ids])
              if branch_que.present?
                questions_id = branch_que.map(&:id)
                p questions_id
                questions = Question.joins("left join branch_questions bq on questions.id = bq.question_id")
                .select("questions.id, questions.types, questions.name, questions.full_text,
                    questions.content, bq.content bq_content, bq.resource_url, bq.options, bq.answer")
                .where(["bq.id is not null and questions.id = (?)", questions_id])
                @status = true
                @notice = "答题记录读取完成"
                @notice += ",未找到相关大题" if questions.length == 0
                @notice += "！"
                @questions = questions.group_by{|q| q.id}
              else
                @status = true
                @notice = "答题记录读取完成,未找到相关大题！"
              end
            else
              @notice = "该学生#{Question::TYPES_NAME[types]}题没有答错的题目！"
            end
        else
          @notice = "该学生答题记录不存在！"
        end
      end
    else
      @notice = "该学生答题记录不存在！"
    end
  end

  #显示原题
  def show_questions
    question_id = params[:question_id].to_i
    @question = nil
    if question_id
      @question = Question.joins("left join branch_questions bq on questions.id = bq.question_id")
              .select("questions.id, questions.types, questions.name, questions.full_text,
                  questions.content, bq.content bq_content, bq.resource_url, bq.options, bq.answer")
              .where("bq.id is not null and questions.id = ?", question_id)
    end
  end

  #显示标签
  def show_all_tags
    question_id = params[:question_id].to_i
    @tags = nil
    @status = false
    @notice = "获取失败！"
    if question_id
      tags = BranchQuestion.joins("left join btags_bque_relations bbr
            on branch_questions.id = bbr.branch_question_id")
            .joins("left join branch_tags bt on bbr.branch_tag_id = bt.id")
            .select("bt.name")
            .where("bbr.id is not null and bt.id is not null and branch_questions.question_id = ?", question_id)
      @tags = tags.to_json
      @status = true
      @notice = "标签加载完成！"
    end
  end
end
