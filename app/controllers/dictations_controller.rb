class DictationsController < ApplicationController
  before_filter :get_course_and_tm, :get_school_classes, :only => [:first, :index], :only => [:first]
  
  def first
    render :layout => "welcome"
  end

  def create_teaching_material
    course_id, tm_name = params[:course_id], params[:teaching_material_name]
    course = Course.find_by_id course_id
    teaching_material = course.teaching_materials.build(:name => tm_name, :status => TeachingMaterial::STATUS[:NORMAL] )

    if teaching_material.save
      @teachingmaterial = course.teaching_materials.where(:status => TeachingMaterial::STATUS[:NORMAL]).group_by{|tm| tm.course_id}
      render :partial => "select_tm"
    else
      render :text => "-1"
    end
  end

  def index
  end

  def get_school_classes
    teacher_id = cookies[:teacher_id]
    teacher = Teacher.find_by_id teacher_id.to_i
    school_classes = teacher.school_classes
    if school_classes && teacher.last_visit_class_id.present?
      school_class = SchoolClass.find_by_id teacher.last_visit_class_id
      redirect_to "/school_classes/#{school_class.id}/dictation_practises"
    end  
  end  

  def get_course_and_tm
    @courses = Course.normal.dictation
    teachingmaterial = TeachingMaterial.where(:course_id => @courses.map(&:id), :status => TeachingMaterial::STATUS[:NORMAL])
    @teachingmaterial = teachingmaterial.group_by{|tm| tm.course_id}
  end

  def show_course
    @course = Course.find_by_id params[:course_id]
  end

  def new_material

  end 

  def show_classes
    teacher_id = cookies[:teacher_id]
    teacher_id = teacher_id.to_i
    @school_classes = SchoolClass.where(["types = ? and teacher_id = ?", SchoolClass::TYPES[:dictation], teacher_id])
    render :layout => "welcome"
  end  
end