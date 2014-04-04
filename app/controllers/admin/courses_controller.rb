#encoding: utf-8
class Admin::CoursesController < ApplicationController
	layout "admin"
  require 'will_paginate/array'
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
    @teaching_materials = TeachingMaterial.where(["course_id in (?)", @page_courses.map(&:id)]).group_by{|tm|
      tm.course_id} if @page_courses
	end

  def destroy
    Course.transaction do
      course = Course.find_by_id(params[:id].to_i)
      if course.update_attribute("status", Course::STATUS[:DELETED])
        flash[:notice] = "删除成功!"
      else
        flash[:notice] = "删除失败!"
      end
      redirect_to "/admin/courses"
    end
  end
end