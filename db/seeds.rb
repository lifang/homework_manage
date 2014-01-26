#encoding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# id, name, nickname, avatar_url, alias_name, qq_uid, status, last_visit_class_id, register_status, created_at, updated_at

TeachingMaterial.create(:id => 1,:name => "牛津英语")
TeachingMaterial.create(:id => 2,:name => "新目标英语")
TeachingMaterial.create(:id => 3,:name => "新概念英语")

TeachingMaterial.transaction do
  TeachingMaterial.find_each do |tm|
    10.times.each do |i|
      cell = tm.cells.create(:name => "第#{i+1}单元")
      10.times do |j|
        cell.episodes.create(:name => "第#{j+1}课")
      end
    end
  end
end