#encoding: utf-8
class StudentsController < ApplicationController
  require 'will_paginate/array'
  before_filter :sign?, :get_unread_messes
  before_filter :get_school_class
  def index
    @schoolclass = SchoolClass.find_by_id school_class_id
    @ungrouped = SchoolClassStudentRalastion.where(["school_class_id = ? and tag_id is null", @school_class.id])
    cookies[:student_has_ungrouped] = {:value => "true"} if cookies[:student_has_ungrouped].nil?
    @tags = Tag.where("school_class_id=#{school_class_id}")
    student_situations = Student.list_student(params[:page] ||= 1, school_class_id)
    @student_situations = student_situations[:student_situations]
    @pagenate_student_school_class = student_situations[:student_school_class]
    @schoolclasses = SchoolClass.where(:teacher_id => current_teacher.id)
    @teachingmaterial = TeachingMaterial.all
  end

  def delete_student
    student_id = params[:student_id]
    schoolclassstudentralastion = SchoolClassStudentRalastion.find_by_student_id_and_school_class_id student_id,school_class_id
    if schoolclassstudentralastion && schoolclassstudentralastion.destroy
      @notice = "删除成功。"
    else
      @notice = "删除失败！"
    end
    redirect_to "/school_classes/#{school_class_id}/students"
  end
  
  def tag_student_list
    tag_id = params[:tag_id]
    @tag = Tag.find_by_id tag_id
    if @tag.nil?
      @notice = "标签不存在！"
    else
      @notice = "标签！"
      @student_hastags = Student.student_hastags tag_id,school_class_id
      @student_notags = Student.student_notags school_class_id
    end
  end
  
  def add_student_tag
    tag_id = params[:tag_id]
    student_id = params[:student_id]
    @tag = Tag.find_by_id tag_id
    if @tag.nil?
      @notice = "标签不存在！"
      @status = 0
    else
      schoolclassstudentralastion = SchoolClassStudentRalastion.find_by_student_id_and_school_class_id student_id, school_class_id
      @notice = "添加失败！"
      @status = 0
      if schoolclassstudentralastion.update_attributes(:tag_id => tag_id)
        @notice="添加成功！！！"
        @status = 1
        @student_hastags = Student.student_hastags tag_id,school_class_id
        @student_notags = Student.student_notags school_class_id
      end
    end
  end

  def edit_class
    @teachering_materials = TeachingMaterial.select("id,name")
    @teacher = Teacher.find_by_id cookies[:teacher_id]
  end
  def update_class
    name = params[:class_name]
    teaching_material_id = params[:teaching_material_id]
    period_of_validity = params[:period_of_validity].to_s + " 23:59:59"
    p 111111111111111111,teaching_material_id
    if @school_class.update_attributes(:name=>name,:period_of_validity=>period_of_validity,:teaching_material_id=>teaching_material_id)
      flash[:success] = '更新成功！'
      redirect_to school_class_students_path(@school_class)
    else
      flash[:error] = '更新失败！'
      redirect_to school_class_students_path(@school_class)
    end
  end

  def close_student_ungrouped_mess  #关闭未分组学员信息提示
    status = 1
    if cookies[:student_has_ungrouped].nil?
      status = 0
    else
      cookies[:student_has_ungrouped] = "false"
    end
    render :json => {:status => status}
  end
end
