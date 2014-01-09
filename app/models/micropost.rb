#encoding: utf-8
class Micropost < ActiveRecord::Base
  attr_protected :authentications
  belongs_to :school_class
  USER_TYPES = {:TEACHER => 0, :STUDENT => 1}
  USER_TYPES_NAME = {0 => '教师', 1 => '学生'}
  PER_PAGE = 10

  #获取班级的microposts
  def self.get_microposts school_class, page
    microposts_count = school_class.microposts.count
    page = 0 if microposts_count = 0
    p microposts_count
    pages_count = microposts_count/Micropost::PER_PAGE if microposts_count%2 == 0
    pages_count = (microposts_count/Micropost::PER_PAGE) + 1 if microposts_count%2 != 0
    p pages_count
    start_number = (page-1)*PER_PAGE
    start_number = 0 if start_number < 0
    microposts_sql = "select m.id id from microposts m where m.school_class_id = #{school_class.id}
      limit #{Micropost::PER_PAGE} offset #{start_number}"
    microposts_ids = Micropost.find_by_sql microposts_sql
    p microposts_ids
    ids = "("
    microposts_ids.each_with_index do |e,index|
      if index != 0
        ids += ","
      end
      ids += "#{e.id}"
    end
    ids += ")"
    p ids
    teacher_sql = "SELECT m.id, m.user_id, m.user_types, m.content, m.created_at, t.name, null as nickname,
                t.avatar_url FROM microposts m join teachers t on m.user_id = t.id where user_types = 0
                and m.id in #{ids}"
    teacher_microposts = Micropost.find_by_sql teacher_sql
    student_sql = "SELECT m.id, m.user_id, m.user_types, m.content, m.created_at, s.name, s.nickname,
                s.avatar_url FROM microposts m join students s on m.user_id = s.id where user_types = 1
                and m.id in #{ids}"
    student_microposts = Micropost.find_by_sql student_sql
    microposts = teacher_microposts + student_microposts
    microposts = microposts.sort_by {|m| m.created_at}
    return_info = {:page => page, :pages_count => pages_count, :microposts => microposts}
  end
end