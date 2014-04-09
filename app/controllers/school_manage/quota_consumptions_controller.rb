#encoding: utf-8
class SchoolManage::QuotaConsumptionsController < ApplicationController
  layout "school_manage"

  def index
  	@teacher = Teacher.where("types = #{Teacher::TYPES[:SCHOOL]}").first
  end 	

  #加载购买配额页面
  def load_quota_consumptions_panel
  	@teacher_id	= params[:teacher_id]
  end	

  #申请学生配额
  def apply_quota_consumptions
  	
  end	
end