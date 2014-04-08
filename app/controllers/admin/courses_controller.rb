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
    Course.transaction do
      name = params[:new_course_name]
      course = Course.create(:name => name, :status => Course::STATUS[:NORMAL])
      if course.save
        flash[:notice] = "科目创建成功!"
      else
        flash[:notice] = "科目创建失败!"
      end
      redirect_to "/admin/courses"
    end
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

  #新建教材
  def new_teach_material
    TeachingMaterial.transaction do
      status = 1
      name = params[:new_teach_material_name]
      course_id = params[:new_teach_material_course_id]
      tm = TeachingMaterial.new(:name => name.nil? || name == "" ? "" : name.strip, :course_id => course_id.to_i,
        :status => TeachingMaterial::STATUS[:NORMAL])
      if tm.save
        status = TeachingMaterial.upload_xls(course_id.to_i, tm.id, params[:new_teach_material_xls])
        if status == 2
          tm.destroy
        end
      else
        status = 0
      end

      if status == 1
        flash[:notice] = "教材创建成功!"
      elsif status == 0
        flash[:notice] = "教材创建失败!"
      elsif status == 2
        flash[:notice] = "文件读取失败!"
      end
      redirect_to "/admin/courses"
    end
  end

  #新建科目或教材重名验证
  def new_course_and_teach_material_valid
    type = params[:type].to_i
    name = params[:name]
    status = 0
    if type == 1  #科目
      course = Course.find_by_name_and_status(name, Course::STATUS[:NORMAL])
      if course.nil?
        status = 1
      end
    elsif type == 2
      course_id = params[:course_id].to_i
      tm = TeachingMaterial.find_by_name_and_course_id_and_status(name, course_id, TeachingMaterial::STATUS[:NORMAL])
      if tm.nil?
        status = 1
      end
    end
    render :json => {:status => status}
  end

end