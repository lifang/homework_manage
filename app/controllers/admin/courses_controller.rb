#encoding: utf-8
class Admin::CoursesController < ApplicationController
	layout "admin"
  require 'will_paginate/array'
  skip_before_filter :get_teacher_infos
	def index
    @course_id = params[:course_id]
    @all_courses = Course.where(["status = ?", Course::STATUS[:NORMAL]])

    if @course_id.nil? || @course_id.to_i==0
      courses = @all_courses
    else
      courses = Course.find_by_sql(["select * from courses where id = ? and status = ?", @course_id.to_i,
          Course::STATUS[:NORMAL]])
    end
    
    @page_courses = courses.paginate(:page => params[:page] ||= 1, :per_page => Course::PER_PAGE) if courses.any?
    @teaching_materials = TeachingMaterial.where(["status = ? and course_id in (?)", TeachingMaterial::STATUS[:NORMAL],
        @page_courses.map(&:id)]).group_by{|tm|
      tm.course_id} if @page_courses
	end

  #删除科目
  def destroy
    Course.transaction do
      course = Course.find_by_id(params[:id].to_i)
      if course.update_attribute("status", Course::STATUS[:DELETED])
        status = 1
      else
        status = 0
      end
      render :json => {:status => status}
    end
  end

  #新建科目
  def create

  end
  
  #删除教材
  def del_teaching_material
    TeachingMaterial.transaction do
      t_m_id = params[:teaching_material_id]
      t_material = TeachingMaterial.find_by_id(t_m_id)
      if t_material.update_attribute("status", TeachingMaterial::STATUS[:DELETED])
        status = 1
      else
        status = 0
      end
      render :json => {:status => status}
    end
  end
end