#encoding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# id, name, nickname, avatar_url, alias_name, qq_uid, status, last_visit_class_id, register_status, created_at, updated_at
#
#TeachingMaterial.create(:id => 1,:name => "牛津英语")
#TeachingMaterial.create(:id => 2,:name => "新目标英语")
#TeachingMaterial.create(:id => 3,:name => "新概念英语")
#
#TeachingMaterial.transaction do
#  TeachingMaterial.find_each do |tm|
#    10.times.each do |i|
#      cell = tm.cells.create(:name => "第#{i+1}单元")
#      10.times do |j|
#        cell.episodes.create(:name => "第#{j+1}课")
#      end
#    end
#  end
#end
#
#BranchTag.create(:name => "名词复数")
#BranchTag.create(:name => "定冠词")
#BranchTag.create(:name => "不定冠词")
#BranchTag.create(:name => "一般陈述句")
#BranchTag.create(:name => "一般疑问句")
#BranchTag.create(:name => "特殊疑问句")
#BranchTag.create(:name => "感叹句")
#BranchTag.create(:name => "形容词后置")

CardTag.create(:name => "名词复数")
CardTag.create(:name => "定冠词")
CardTag.create(:name => "不定冠词")
CardTag.create(:name => "一般陈述句")
CardTag.create(:name => "一般疑问句")
CardTag.create(:name => "特殊疑问句")
CardTag.create(:name => "感叹句")
CardTag.create(:name => "形容词后置")

# (1..4).each do |id|
# 	Student.create(:nickname => "Student#{id}", :status => Student::STATUS[:YES], :user_id => id)
# 	User.create(:name => "name#{id}")
# 	SchoolClassStudentRalastion.create(:student_id => id, :school_class_id =>1)
# end

# teacher = Teacher.find_by_types(Teacher::TYPES[:SYSTEM])
# unless teacher
#   user = User.create({:name => "sys_admin", :avatar_url => "/assets/default_avater.jpg"})
#   Teacher.create({:email => "mailer@comdosoft.com", :status => Teacher::STATUS[:YES],
#       :password =>  Digest::SHA2.hexdigest("admin123"),
#       :types => Teacher::TYPES[:SYSTEM], :user_id => user.id})

# end



system_admin = Teacher.find_by_types(Teacher::TYPES[:SYSTEM])  #系统管理员
unless system_admin
  user = User.create({:name => "sys_admin", :avatar_url => "/assets/default_avater.jpg"})
  Teacher.create({:email => "mailer@comdosoft.com", :status => Teacher::STATUS[:YES],
      :password =>  Digest::SHA2.hexdigest("admin123"),
      :types => Teacher::TYPES[:SYSTEM], :user_id => user.id})
end

