#encoding:utf-8
class MainPagesController < ApplicationController
  before_filter :get_school_class
  def index
    @class_index =-1
    @init_mid = params[:init_mid]
    @single_m = params[:single_m]
    @condition =  params[:condtions]=="" ? nil : params[:condtions]
    @scclass = SchoolClass.find(@school_class.id)
    @classmates = SchoolClass::get_classmates(@scclass)
    if @single_m.nil? || @single_m.to_i != 1
      array = Micropost::get_microposts @scclass,params[:page],@condition
      @microposts =array[:details_microposts]
    else
      @microposts = Micropost.paginate_by_sql(["select m.id micropost_id, m.user_id, m.user_types, m.content, m.created_at,
                m.reply_microposts_count, u.name, u.avatar_url  from microposts m
                inner join users u on u.id = m.user_id where m.id=?", @init_mid], :per_page => Micropost::PER_PAGE, :page => 1)
    end
  end
end
