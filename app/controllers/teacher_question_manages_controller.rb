#encoding: utf-8
class TeacherQuestionManagesController < ApplicationController  #教师题库管理
  before_filter :get_school_class
  def index
    @last_re = request.referer
    @search_type = params[:search_type]
    if @search_type.nil?
      get_question_init
    elsif @search_type == "teaching_material"
      @t_m_id = params[:teaching_material_id]
      if @t_m_id.to_i == 0
        get_question_init
      else
        school_classes = SchoolClass.where(["teacher_id=? and status=? and teaching_material_id=?", current_teacher.id,
            SchoolClass::STATUS[:NORMAL], @t_m_id])
        question_packages = QuestionPackage.select("id").where(["school_class_id in (?)", school_classes.map(&:id)]) if school_classes.any?
        @questions = Question.paginate_by_sql(["select q.*,c.name cname, e.name ename from questions q inner join cells c on q.cell_id=c.id
      left join episodes e on q.episode_id=e.id where q.question_package_id in (?)", question_packages.map(&:id)],
          :page => params[:page] ||=1, :per_page => Question::PER_PAGE) if question_packages && question_packages.any?
        @cells = Cell.select("id, name").where(["teaching_material_id=?", @t_m_id.to_i]) if @t_m_id && @t_m_id.to_i != 0
      end
    elsif @search_type == "cell"
      t_m_id = params[:teaching_material_id]
      @cell_id = params[:cell_id]
      school_classes = SchoolClass.where(["teacher_id=? and status=? and teaching_material_id=?", current_teacher.id,
          SchoolClass::STATUS[:NORMAL], t_m_id])
      question_packages = QuestionPackage.select("id").where(["school_class_id in (?)", school_classes.map(&:id)]) if school_classes.any?
      if @cell_id.to_i == 0
        @questions = Question.paginate_by_sql(["select q.*,c.name cname, e.name ename from questions q inner join cells c on q.cell_id=c.id
      left join episodes e on q.episode_id=e.id where q.question_package_id in (?)", question_packages.map(&:id)],
          :page => params[:page] ||=1, :per_page => Question::PER_PAGE) if question_packages && question_packages.any?
      else
        @questions = Question.paginate_by_sql(["select q.*,c.name cname, e.name ename from questions q inner join cells c on q.cell_id=c.id
      left join episodes e on q.episode_id=e.id where q.question_package_id in (?) and q.cell_id=?", question_packages.map(&:id), @cell_id.to_i],
          :page => params[:page] ||=1, :per_page => Question::PER_PAGE) if question_packages && question_packages.any?
        @episodes = Episode.where(["cell_id=?", @cell_id.to_i])
      end
    elsif @search_type == "episode"
      t_m_id = params[:teaching_material_id]
      cell_id = params[:cell_id]
      @episode_id = params[:episode_id]
      school_classes = SchoolClass.where(["teacher_id=? and status=? and teaching_material_id=?", current_teacher.id,
          SchoolClass::STATUS[:NORMAL], t_m_id])
      question_packages = QuestionPackage.select("id").where(["school_class_id in (?)", school_classes.map(&:id)]) if school_classes.any?
      if @episode_id.to_i == 0
        @questions = Question.paginate_by_sql(["select q.*,c.name cname, e.name ename from questions q inner join cells c on q.cell_id=c.id
      left join episodes e on q.episode_id=e.id where q.question_package_id in (?) and q.cell_id=?", question_packages.map(&:id), cell_id.to_i],
          :page => params[:page] ||=1, :per_page => Question::PER_PAGE) if question_packages && question_packages.any?
      else
        @questions = Question.paginate_by_sql(["select q.*,c.name cname, e.name ename from questions q inner join cells c on q.cell_id=c.id
      left join episodes e on q.episode_id=e.id where q.question_package_id in (?) and q.cell_id=? and q.episode_id=?", question_packages.map(&:id), cell_id.to_i, @episode_id.to_i],
          :page => params[:page] ||=1, :per_page => Question::PER_PAGE) if question_packages && question_packages.any?
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
      left join episodes e on q.episode_id=e.id where q.question_package_id in (?) and q.cell_id=? and q.episode_id=?", question_packages.map(&:id), cell_id.to_i, episode_id.to_i],
          :page => params[:page] ||=1, :per_page => Question::PER_PAGE) if question_packages && question_packages.any?
      else
        @questions = Question.paginate_by_sql(["select q.*,c.name cname, e.name ename from questions q inner join cells c on q.cell_id=c.id
      left join episodes e on q.episode_id=e.id where q.question_package_id in (?) and q.cell_id=? and q.episode_id=? and q.types=?", question_packages.map(&:id), cell_id.to_i,
            episode_id.to_i, type],
          :page => params[:page] ||=1, :per_page => Question::PER_PAGE) if question_packages && question_packages.any?
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
      question = Question.find_by_id(q_id)
      if question.update_attribute("if_shared", Question::IF_SHARED[:YES])
        status = 1
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
        bqs = BranchQuestion.where(["question_id = ?", question.id]) if question
        BtagsBqueRelation.delete_all(["branch_question_id in (?)", bqs.map(&:id)]) if bqs
        bqs.each do |bq|
          bq.destroy
        end if bqs
        question.destroy
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
      left join episodes e on q.episode_id=e.id where q.question_package_id in (?)", question_packages.map(&:id)],
      :page => params[:page] ||=1, :per_page => Question::PER_PAGE) if question_packages && question_packages.any?
  end

end