#encoding: utf-8
class TagsController < ApplicationController
  before_filter :sign?
  def destroy
    tag_id = params[:id]
    tag = Tag.find_by_id tag_id
    @notice = "删除失败"
    @status = 0
    begin
      Tag.transaction do
        schoolclassstudentralastion = SchoolClassStudentRalastion.where("tag_id=#{tag_id}")
        if tag.destroy
          @status = 1
        end
        if schoolclassstudentralastion.present?
          schoolclassstudentralastion.update_all(:tag_id => nil )
        end
      end
    end
    if @status
      @notice = "删除成功"
    end
    @tags = Tag.where("school_class_id=#{school_class_id}")
  end
  
  def create
    name = params[:name_tag]
    tag = Tag.find_by_name_and_school_class_id name,school_class_id
    @status = 0
    if tag
      @notice = "标签已存在"
    else
      @status = 1
      @notice = "标签创建成功"
      Tag.create(:name => name,:school_class_id => school_class_id)
    end
    @tags = Tag.where("school_class_id=#{school_class_id}")
  end

  #tag 列表
  def delete_student_tag
    student_id = params[:student_id]
    schoolclassstudentralastion = SchoolClassStudentRalastion.find_by_student_id_and_school_class_id student_id,school_class_id
    tag = Tag.where("school_class_id=#{school_class_id}")
    status=0
    if schoolclassstudentralastion
      status=1
    end
    render :json => {:status => status,:tag => tag,:schoolclassstudentralastion => schoolclassstudentralastion}
  end
  #  重新分组
  def choice_tags
    tag_id = params[:tag_id]
    student_id = params[:student_id]
    schoolclassstudentralastion = SchoolClassStudentRalastion.find_by_student_id_and_school_class_id student_id,school_class_id
    if schoolclassstudentralastion
      schoolclassstudentralastion.update_attributes(:tag_id => tag_id)
    end
    redirect_to "/school_classes/#{school_class_id}/students"
  end
end