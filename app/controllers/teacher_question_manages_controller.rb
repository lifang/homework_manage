#encoding: utf-8
class TeacherQuestionManagesController < ApplicationController  #教师题库管理
  before_filter :get_school_class
  
  def index
    @last_re = request.referer
    @search_type = params[:search_type]
    if @search_type.nil?
      school_classes = SchoolClass.where(["teacher_id=? and status=?", current_teacher.id, SchoolClass::STATUS[:NORMAL]])
      teach_materials = TeachingMaterial.where(["id in (?)", school_classes.map(&:teaching_material_id)])if school_classes.any?
      @courses = Course.where(["id in (?) and status=? ", teach_materials.map(&:course_id), Course::STATUS[:NORMAL]]) if teach_materials
      question_packages = QuestionPackage.select("id").where(["school_class_id in (?)", school_classes.map(&:id)]) if school_classes.any?
      @questions = Question.get_questions(question_packages.map(&:id), params[:page] ||=1) if question_packages && question_packages.any?
    elsif @search_type == "teaching_material"
      @t_m_id = params[:teaching_material_id]
      if @t_m_id.to_i == 0
        school_classes = SchoolClass.where(["teacher_id=? and status=?", current_teacher.id, SchoolClass::STATUS[:NORMAL]])
        question_packages = QuestionPackage.select("id").where(["school_class_id in (?)", school_classes.map(&:id)]) if school_classes.any?
        @questions = Question.get_questions(question_packages.map(&:id), params[:page] ||=1) if question_packages && question_packages.any?
      else
        @cells = Cell.select("id, name").where(["teaching_material_id=?", @t_m_id.to_i]) if @t_m_id && @t_m_id.to_i != 0
        school_classes = SchoolClass.where(["teacher_id=? and status=? and teaching_material_id=?", current_teacher.id,
            SchoolClass::STATUS[:NORMAL], @t_m_id])
        question_packages = QuestionPackage.select("id").where(["school_class_id in (?)", school_classes.map(&:id)]) if school_classes.any?
        @questions = Question.get_questions(question_packages.map(&:id), params[:page] ||=1) if question_packages && question_packages.any?
      end
    elsif @search_type == "cell"
      t_m_id = params[:teaching_material_id]
      @cell_id = params[:cell_id]
      school_classes = SchoolClass.where(["teacher_id=? and status=? and teaching_material_id=?", current_teacher.id,
          SchoolClass::STATUS[:NORMAL], t_m_id])
      question_packages = QuestionPackage.select("id").where(["school_class_id in (?)", school_classes.map(&:id)]) if school_classes.any?
      if @cell_id.to_i == 0
        @questions = Question.get_questions(question_packages.map(&:id), params[:page] ||=1) if question_packages && question_packages.any?
      else
        @episodes = Episode.where(["cell_id=?", @cell_id.to_i])
        @questions = Question.get_questions(question_packages.map(&:id), params[:page] ||=1, @cell_id) if question_packages && question_packages.any?
      end
    elsif @search_type == "episode"
      t_m_id = params[:teaching_material_id]
      cell_id = params[:cell_id]
      @episode_id = params[:episode_id]
      school_classes = SchoolClass.where(["teacher_id=? and status=? and teaching_material_id=?", current_teacher.id,
          SchoolClass::STATUS[:NORMAL], t_m_id])
      question_packages = QuestionPackage.select("id").where(["school_class_id in (?)", school_classes.map(&:id)]) if school_classes.any?
      if @episode_id.to_i == 0
        @questions = Question.get_questions(question_packages.map(&:id), params[:page] ||=1, cell_id.to_i) if question_packages && question_packages.any?
      else
        @questions = Question.get_questions(question_packages.map(&:id), params[:page] ||=1, cell_id.to_i, @episode_id.to_i) if question_packages && question_packages.any?
      end
    elsif @search_type == "type"
      t_m_id = params[:teaching_material_id].to_i
      cell_id = params[:cell_id].to_i
      episode_id = params[:episode_id].to_i
      type = params[:type_id].to_i
      t_m_id = params[:teaching_material_id]
      school_classes = SchoolClass.where(["teacher_id=? and status=? and teaching_material_id=?", current_teacher.id,
          SchoolClass::STATUS[:NORMAL], t_m_id])
      question_packages = QuestionPackage.select("id").where(["school_class_id in (?)", school_classes.map(&:id)]) if school_classes.any?
      if type == -1
        @questions = Question.paginate_by_sql(["select q.*,c.name cname, e.name ename from questions q inner join cells c on q.cell_id=c.id
      left join episodes e on q.episode_id=e.id where q.question_package_id in (?) and q.status=? and q.cell_id=? and q.episode_id=?", question_packages.map(&:id), Question::STATUS[:NORMAL], cell_id.to_i, episode_id.to_i],
          :page => params[:page] ||=1, :per_page => Question::PER_PAGE) if question_packages && question_packages.any?
        @questions = Question.get_questions(question_packages.map(&:id), params[:page] ||=1, cell_id, episode_id) if question_packages && question_packages.any?
      else
        @questions = Question.get_questions(question_packages.map(&:id), params[:page] ||=1, cell_id, episode_id, type) if question_packages && question_packages.any?
      end
    end
    respond_to do |f|
      f.js
      f.html
    end
  end


  def share_question  #分享题目
    Question.transaction do
      status = 0
      q_id = params[:q_id].to_i
      name = params[:name]
      question = Question.find_by_id(q_id)
      question_pack = question.question_package
      unless question.if_shared
        branch_questions = question.branch_questions
        if branch_questions.present?
          share_question = ShareQuestion.create({:user_id => current_user.id, :name => name, :types => question.types,
              :cell_id => question.cell_id, :episode_id => question.episode_id, :questions_time => question.questions_time,
              :full_text => question.full_text})
          if share_question
            question.branch_questions.each do |bq|
              new_resource_url = copy_file(share_media_path, question_pack, bq, bq.resource_url) if bq.resource_url.present? #分享的时候，拷贝音频
              new_content =  bq.content
              #选择题的话，内容里面有资源，复制资源
              if bq.types == Question::TYPES[:SELECTING] && bq.content.present? && bq.content.include?("<file>")
                content = bq.content.split("</file>")[1]
                content_file = bq.content.split("</file>")[0].split("<file>")[1]
                new_content_file = copy_file(share_media_path, question_pack, bq, content_file) if content_file.present?
                new_content = "<file>#{new_content_file}</file>#{content}"
              end
              sbq = share_question.share_branch_questions.new({:content => new_content, :resource_url => new_resource_url,
                  :options => bq.options, :answer => bq.answer, :types => bq.types})

              bq.branch_tags.each do |bt|
                sbq.branch_tags << bt
              end
              sbq.save
            end
          end
          question.update_attributes(:if_shared => true, :name => name)
          status = 0 #分享成功
        else
          status = 2 #大题下面无小题，提示
        end
      else
        status = 1 #已经分享过
      end
      render :json => {:status => status}
    end
  end

  def delete_question   #删除题目
    Question.transaction do
      begin
        status = 1
        q_id = params[:q_id].to_i
        question = Question.find_by_id(q_id)
        question.update_attribute("status", Question::STATUS[:DELETED])
      rescue
        status = 0
      end
      render :json => {:status => status}
    end
  end

  def select_course
    course_id = params[:course_id]
    @teaching_materials = TeachingMaterial.where(["course_id=?", course_id])
  end

  def get_question_init
    school_classes = SchoolClass.where(["teacher_id=? and status=?", current_teacher.id, SchoolClass::STATUS[:NORMAL]])
    teach_materials = TeachingMaterial.where(["id in (?)", school_classes.map(&:teaching_material_id)])if school_classes.any?
    @courses = Course.where(["id in (?) and status=? ", teach_materials.map(&:course_id), Course::STATUS[:NORMAL]]) if teach_materials
    question_packages = QuestionPackage.select("id").where(["school_class_id in (?)", school_classes.map(&:id)]) if school_classes.any?
    @questions = Question.paginate_by_sql(["select q.*,c.name cname, e.name ename from questions q inner join cells c on q.cell_id=c.id
      left join episodes e on q.episode_id=e.id where q.question_package_id in (?) and q.status=?", question_packages.map(&:id), Question::STATUS[:NORMAL]],
      :page => params[:page] ||=1, :per_page => Question::PER_PAGE) if question_packages && question_packages.any?
  end


end