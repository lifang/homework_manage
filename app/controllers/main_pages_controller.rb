#encoding:utf-8
class MainPagesController < ApplicationController
  def index
     @scclass = SchoolClass.find(current_teacher.last_visit_class_id)
     @classmates = SchoolClass::get_classmates(@scclass)
     array = Micropost::get_microposts @scclass,params[:page],current_teacher.user_id
     @microposts =array[:details_microposts]
  end
end
