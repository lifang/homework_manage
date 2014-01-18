class WelcomeController < ApplicationController
  layout 'welcome'
  def index
  end

  #教师第一次注册后跳转页面
  def first
   @teachering_materials = TeachingMaterial.select("id,name")
  end
end
