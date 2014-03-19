#encoding: utf-8
include StatisticsHelper
class StatisticsController < ApplicationController
  #layout "tapplication"
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
  end

  #正确率列表——显示某一类型（学生做错的题目）原题
  def show_incorrect_questions
    types = params[:question_types].to_i
    student_answer_record_id = params[:student_answer_record_id]
    student_answer_record = StudentAnswerRecord.find_by_id student_answer_record_id
    record_details = RecordDetail.find_by_student_answer_record_id student_answer_record.id unless student_answer_record.nil?
    @status = false
    @origin_questions = nil
    @notice = "该学生的答题记录不存在！"
    if !student_answer_record.nil? && !student_answer_record.answer_file_url.nil?
      if record_details.nil?
        @notice = "该学生的#{Question::TYPES_NAME[:question_types]}答题记录为空！"
      else
        anwser_file_url = "#{Rails.root}/public#{student_answer_record.answer_file_url}"
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
              ques_id = BranchQuestion
                .joins("left join questions q on branch_questions.question_id = q.id")
                .select("distinct q.id")
                .where(["branch_questions.id in (?) and q.id is not null",wrong_ids])
              if ques_id.present?
                questions_id = ques_id.map(&:id)
                questions = Question
                  .select("questions.id, questions.types, questions.name, questions.full_text,
                    questions.content")
                  .where(["questions.id in (?)", questions_id])
                branch_questions = BranchQuestion
                  .select("content, resource_url, options, answer, question_id")
                  .where(["question_id in (?)", questions_id])
                  .group_by {|b| b.question_id}
                #p questions
                #p branch_questions
                if questions.present?
                  ques = []
                  questions.each do |q|
                    branch_ques = []
                    if branch_questions[q.id].present?
                      branch_ques = branch_questions[q.id]
                    end
                    ques << {:id => q.id, :name => q.name, :types => q.types, :full_text => q.full_text,
                    :content => q.content, :branch_questions => branch_ques}
                  end
                  @origin_questions = {:types => types, :questions => ques}
                  p @origin_questions
                  @status = true
                  @notice = "答题记录读取完成"
                  @notice += ",未找到相关大题" if questions.length == 0
                  @notice += "！"
                else
                  @status = false
                  @notice = "没有找到相关题目！"
                end
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
    @origin_questions = nil
    ques = []
    if question_id
      question = Question
      .select("questions.id, questions.types, questions.name, questions.full_text,
                    questions.content")
      .where(["questions.id in (?)", question_id])
      branch_questions = BranchQuestion
      .select("content, resource_url, options, answer, question_id")
      .where(["question_id in (?)", question_id])
      .group_by {|b| b.question_id}
      question.each do |q|
        branch_ques = []
        if branch_questions[q.id].present?
          branch_ques = branch_questions[q.id]
        end
        ques << {:id => q.id, :name => q.name, :types => q.types, :full_text => q.full_text,
                 :content => q.content, :branch_questions => branch_ques}
      end
      @origin_questions = {:types => question[0].types, :questions => ques}
    end
    p @origin_questions
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
