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
  	number = params[:number]
  	teacher_id = params[:teacher_id]
  	teacher = Teacher.find_by_id teacher_id
  	@status = false
  	@notice = "申请人信息错误!"
  	if teacher.present?
  		admin = Teacher.where("types = #{Teacher::TYPES[:SYSTEM]} and status = #{Teacher::STATUS[:YES]}").first
  		if admin.present?
  			content = "#{teacher.user.name}于#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}申请了#{number}个学生配额!"
 			
 			if AdminMessage.create(:sender_id => teacher.id, :receiver_id => admin.id, :content => content )
 				UserMailer.apply_quota_consumptions(email, sender_name, school_name, number, type)
 				@status = false
  				@notice = "申请成功!"
 			else
 				@notice = "申请失败!"	
 			end	
  		else
  			@notice = "系统管理员不存在!"	
  		end		
  		
  	end		
  end	
end