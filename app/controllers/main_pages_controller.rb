#encoding:utf-8
class MainPagesController < ApplicationController
  def index
    p session[:teacher_id]
     scclass = SchoolClass.find(current_teacher.last_visit_class_id)
     array = Micropost::get_microposts scclass,1,1
     @microposts =array[:details_microposts]
     p 111111111111111,@microposts
  end
end
