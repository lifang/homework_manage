#encoding: utf-8
include StatisticsHelper
class StatisticsController < ApplicationController
  before_filter :sign?, :get_unread_messes
  before_filter :get_school_class
  #完成率及正确率统计
  def index
    school_class_id = params[:school_class_id]
    school_class = SchoolClass.find_by_id school_class_id
    @today_date = Time.now.strftime("%Y-%m-%d")
    info = PublishQuestionPackage.get_homework_statistics @today_date, school_class
    @all_tags = info[:all_tags]
    @current_task = info[:current_task]
    @current_date =  @current_task.nil? ? @today_date : @current_task.created_at.strftime("%Y-%m-%d")
    @students = info[:students]
    @question_types = info[:question_types]
    p @question_types 
    @student_answer_records = info[:student_answer_records]
    @average_correct_rate = info[:average_correct_rate]
    @average_complete_rate = info[:average_complete_rate]
    @record_details = info[:record_details]
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
    @students = info[:students]
    @question_types = info[:question_types]
    @student_answer_records = info[:student_answer_records]
    @average_correct_rate = info[:average_correct_rate]
    @average_complete_rate = info[:average_complete_rate]
    @record_details = info[:record_details]
  end

  #根据标签显示完成率及正确率统计
  def show_tag_task
    pub_id = params[:pub_id].to_i
    @current_task = PublishQuestionPackage.find_by_id pub_id
    info = PublishQuestionPackage.get_record_details(@current_task, @current_task.school_class_id)
    @question_types = info[:question_types]
    @student_answer_records = info[:student_answer_records]
    @students = info[:students]
    @average_complete_rate = info[:average_complete_rate]
    @average_correct_rate = info[:average_correct_rate]
    @record_details = info[:record_details]
  end

  #获取该任务下题型统计信息
  def show_question_statistics
    pub_id = params[:pub_id].to_i
    school_class_id = params[:school_class_id]
    publish_question_package = PublishQuestionPackage.find_by_id pub_id
    tag_id = publish_question_package.tag_id unless publish_question_package.nil?
    info = PublishQuestionPackage.get_quetion_types_statistics(publish_question_package, school_class_id)
    @question_types = info[:question_types]
    @questions = info[:questions]
    @branch_questions = info[:branch_questions]
    @used_times = info[:used_times]
    @questions_answers = info[:questions_answers]
    @types_rate = info[:types_rate]
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
              .select("id,content, resource_url, options, answer, question_id")
              .where(["question_id in (?)", questions_id])
              .group_by {|b| b.question_id}
              # p questions
              # p branch_questions
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
                @wrong_ids = wrong_ids
                @status = true
                @notice = "答题记录读取完成"
                @notice += ",未找到相关大题" if questions.length == 0
                @notice += "！"
              else
                @status = false
                @notice = "未找到相关题目！"
              end
            else
              @status = false
              @notice = "未找到相关题目！"
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
    types = params[:types].to_i
    branch_id = params[:branch_id]
    @questions = nil
    branch_question = BranchQuestion.find_by_id branch_id
    # branch_question = BranchQuestion.find_by_id_and_types branch_id, types
    ques = []
    @status = false
    if branch_question
      question = branch_question.question
      if question.present?
        branch_questions = question.branch_questions
                                .select("content, resource_url, options, answer, question_id")
                                .where("branch_questions.id = ?",branch_id)
        ques = []
        ques << {:id => question.id, :name => question.name, :types => question.types, :full_text => question.full_text,
                    :content => question.content, :branch_questions => branch_questions}
        @origin_questions = {:types => question.types, :questions => ques}
        @status = true
      else
        @notice = "未找到原题，原题可能已经删除！"    
      end 
      
    else
      @notice = "未找到原题，原题可能已经删除！"
    end
  end

  #显示标签
  def show_all_tags
    branch_id = params[:branch_id].to_i
    @tags = nil
    @status = false
    @notice = "获取失败！"
    if branch_id
      tags = BranchQuestion.joins("left join btags_bque_relations bbr
            on branch_questions.id = bbr.branch_question_id")
          .joins("left join branch_tags bt on bbr.branch_tag_id = bt.id")
          .select("bt.name")
          .where("bbr.id is not null and bt.id is not null and branch_questions.id = ?", branch_id).uniq
      @tags = tags.to_json
      if tags.any?
        @all_tags = tags.map(&:name).inject(""){|s,n| s += "<p>"+n+"</p>";s} if tags.any?
      else
        @all_tags = "<p>暂无标签</p>"
      end  
      @status = true

      @notice = "标签加载完成！"
    end
  end
end
