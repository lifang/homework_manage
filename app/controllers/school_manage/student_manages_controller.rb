#encoding: utf-8
class SchoolManage::StudentManagesController < ApplicationController
  layout "school_manage"
  skip_before_filter :get_teacher_infos,:get_unread_messes
  before_filter :check_if_schooladmin, :only => [:index]
  before_filter :get_admin_unread_messes
  def index
    admin = Teacher.find_by_id(cookies[:teacher_id])
    @name = params[:student_name]
    sql = ["select s.*, u.name uname from students s inner join users u on s.user_id=u.id
    where s.school_id = ?", admin.school_id]
    if @name && @name != ""
      sql[0] += " and u.name like ?"
      sql << "%#{@name.strip.gsub(/[%_]/){|x| '\\' + x}}%"
    end
    sql[0] += " order by s.created_at desc"
    @school_id = admin.school_id
    @students = Student.paginate_by_sql(sql, :page => params[:page], :per_page => 10)
    respond_to do |f|
      f.xls {
        veri_code = params[:veri_code]
        school = School.find_by_id(@school_id)
        stus_list = Student.where(["veri_code =? ", veri_code.to_i])
        send_data(
          Student.make_student_list_xls_report(stus_list),
          :type => "text/excel;charset=utf-8; header=present",
          :filename => "#{school.name}第#{veri_code}批学生激活码清单.xls"
        )
      }
      f.html
    end
  end

  def create
    Student.transaction do
      school_id = params[:school_id].to_i
      xls_form = params[:stu_list_form]
      status,veri_code,error_str = Student.upload_student_list_xls(school_id, xls_form)
      if status == 1
        flash[:notice] = "创建成功!"
        flash[:veri_code] = "#{veri_code}"
      elsif status == -1
        flash[:notice] = "学号为:#{error_str}的学生已存在!"
      else
        flash[:notice] = "文件读取失败!"
      end
      redirect_to "/school_manage/student_manages"
    end
  end
  
  #启用或停用学生
  def set_stu_status
    student_id = params[:stu_id].to_i
    Student.transaction do
      status = 0
      student = Student.find_by_id(student_id)
      if student.status == Student::STATUS[:YES]    #停用
        hash = {:status => Student::STATUS[:NO]}
        if student.qq_uid
          hash[:qq_uid] = nil
        end
        if student.update_attributes(hash)
          SchoolClassStudentRalastion.delete_all(["student_id=?", student_id])
          status = 1
        end
      else  #启用
        if student.update_attribute("status", Student::STATUS[:YES])
          status = 1
        end
      end
      render :json => {:status => status}
    end
  end

  #激活该学生
  def activating_student
    student_id = params[:student_id].to_i
    student = Student.find_by_id student_id
    if student
      student.update_attributes(:active_status => Student::ACTIVE_STATUS[:YES])
      status = 1
      notice = "激活成功！"
      content = '你的账户已激活！可以开始答作业'
      extras_hash = {:type => Student::PUSH_TYPE[:sys_message], :student_id => student.id}
      push_method(content, extras_hash, student)
    else
      status = 0
      notice = "学生不存在！"
    end
    render :json => {:status=> status,:notice => notice}
  end

end