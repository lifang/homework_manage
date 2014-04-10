#encoding: utf-8
class SchoolManage::StudentManagesController < ApplicationController
  layout "school_manage"
  skip_before_filter :get_teacher_infos,:get_unread_messes
  before_filter :check_if_schooladmin, :only => [:index]
  def index
    admin = Teacher.find_by_id(1)
    @name = params[:student_name]
    sql = ["select s.*, u.name uname from students s inner join users u on s.user_id=u.id
    where s.school_id = ?", admin.school_id]
    if @name && @name != ""
      sql[0] += " and u.name like ?"
      sql << "%#{@name.strip.gsub(/[%_]/){|x| '\\' + x}}%"
    end
    @school_id = admin.school_id
    @students = Student.paginate_by_sql(sql, :page => params[:page], :per_page => 2)
  end

  def create
    Student.transaction do
      school_id = params[:school_id].to_i
      mc = StudentVeriCode.find_by_sql(["select max(code) m_code from student_veri_codes"]).first
      if mc.m_code.nil?
        max_code = 1001
        StudentVeriCode.create(:code => max_code)
      else
        max_code = mc.m_code + 1
      end
      
    end
  end
  
  #启用或停用学生
  def set_stu_active_status
    student_id = params[:stu_id].to_i
    Student.transaction do
      status = 0
      student = Student.find_by_id(student_id)
      if student && student.active_status == true
        if student.update_attribute("active_status", false)
          status = 1
        end
      elsif student && student.active_status == false
        if student.update_attribute("active_status", true)
          status = 1
        end
      end
      render :json => {:status => status}
    end
  end

end