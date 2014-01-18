#encoding:utf-8
class MainPagesController < ApplicationController
  def index
     scclass = SchoolClass.find(1)
     array = Micropost::get_microposts scclass,1,1
     @microposts =array[:details_microposts]
     p 111111111111111,@microposts
  end
end
