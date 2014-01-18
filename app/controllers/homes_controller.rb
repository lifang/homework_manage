#encoding: utf-8
class HomesController < ApplicationController
  layout "left_navi"
  def index
    @teacher = Teacher.find_by_sql(["select u.name,u.avatar_url from teachers t inner join users u
        on t.user_id=u.id where t.id=1"]).first
    p @teacher
    
  end
end
