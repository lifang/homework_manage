class DictationsController < ApplicationController

  before_filter :get_course_and_tm, :only => [:first, :index]
  
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



  def get_course_and_tm
    @courses = Course.normal.dictation
    teachingmaterial = TeachingMaterial.where(:course_id => @courses.map(&:id), :status => TeachingMaterial::STATUS[:NORMAL])
    @teachingmaterial = teachingmaterial.group_by{|tm| tm.course_id}
  end

  def show_course
    @course = Course.find_by_id params[:course_id]
  end
end