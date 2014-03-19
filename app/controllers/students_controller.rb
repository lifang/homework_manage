#encoding: utf-8
class StudentsController < ApplicationController
  require 'will_paginate/array'
  before_filter :sign?, :get_unread_messes
  before_filter :get_school_class
  def index
    sql_schoolclass = "SELECT *,(select COUNT(*) from school_class_student_ralastions scsr WHERE scsr.school_class_id = ?) count
from school_classes sc where sc.id=?"
    @schoolclass = SchoolClass.find_by_sql([sql_schoolclass,school_class_id,school_class_id])
    @ungrouped = SchoolClassStudentRalastion.where("tag_id is null")
    @tags = Tag.where("school_class_id=#{school_class_id}")
    student_situations = Student.list_student school_class_id
    @student_situations = student_situations.paginate(:page=> params[:page] ||= 1,:per_page=>Student::PER_PAGE )
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
end
