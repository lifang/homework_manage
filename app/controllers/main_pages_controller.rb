#encoding:utf-8
class MainPagesController < ApplicationController
  before_filter :sign?
  before_filter :get_school_class
  def index
    @class_index =-1
    @init_mid = params[:init_mid]
    @condition =  params[:condtions].nil? || params[:condtions].strip=="" ? nil : params[:condtions].strip
    @scclass = SchoolClass.find(@school_class.id)
    @classmates = SchoolClass::get_classmates(@scclass)
    page = @init_mid.nil? || @init_mid.to_i == 0 ? params[:page] : 1
    array = Micropost::get_microposts @scclass,page,@condition
    microposts =array[:details_microposts]
    if @init_mid.nil? || @init_mid.to_i == 0
      @microposts = microposts
    else
      flag = microposts.inject(false){|f,m|
        if m.micropost_id == @init_mid.to_i
          f = true
        end;
        f
      }
      if flag
        @microposts = microposts
        @micropost = Micropost.find_by_id(@init_mid.to_i) if @microposts.any?
        @repiles = (ReplyMicropost::get_microposts @micropost.id,1)[:reply_microposts] if @micropost
      else
        @microposts = Micropost.paginate_by_sql(["select m.id micropost_id, m.user_id, m.user_types, m.content, m.created_at,
                m.reply_microposts_count, u.name, u.avatar_url  from microposts m
                inner join users u on u.id = m.user_id where m.id=?", @init_mid.to_i], :per_page => Micropost::PER_PAGE, :page => 1)
        @micropost = Micropost.find_by_id(@init_mid.to_i) if @microposts.any?
        @repiles = (ReplyMicropost::get_microposts @micropost.id,1)[:reply_microposts] if @micropost
      end
    end
  end
end
