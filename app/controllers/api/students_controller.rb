#encoding: utf-8
class Api::StudentsController < ApplicationController
  def news_release
    content = params[:content]
    user_id = params[:user_id]
    user_types = params[:user_types]
    school_class_id = params[:school_class_id]
    micropost = Micropost.new(:user_id => user_id, :user_types => user_types, :content => content, :school_class_id => school_class_id)
    if micropost.save
      render :json => "success"
    else
      render :json => "fails"
    end
  end

  def login
    qq_uid = params[:qq_uid]
    student = Student.find_by_qq_uid qq_uid
    if student.nil?
      render :json => {:status => "error", :notice => "账号不存在，请注册！"}
    else
      school_class = SchoolClass.find_by_id student.last_visit_class_id
      class_id = nil
      class_name = nil
      tearcher_name = nil
      tearcher_id = nil
      classmates = nil
      if !school_class.nil?
        class_id = school_class.id
        class_name = school_class.name
        tearcher_id = school_class.teacher.id
        tearcher_name = school_class.teacher.name
        classmates = school_class.students
      end
      render :json => {:status => "success", :notice => "登陆成功！",
                       :student => {:id => student.id, :name => student.name,
                                    :nickname => student.nickname, :avatar_url => student.avatar_url},
                       :class => {:id => class_id, :name => class_name, :tearcher_name => tearcher_name,
                                :tearcher_id => tearcher_name },
                       :classmates => classmates,

                      }
    end
  end
end
