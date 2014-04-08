#encoding: utf-8
class School< ActiveRecord::Base
  attr_protected :authentications
  STATUS = {:DELETE => 0,:NORMAL => 1}
  STATUS_NAME = {0=>'已删除',1=>'正常'}
  def self.newpass( len )
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newpass = ""
    1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
    return newpass
  end

  def self.schools_list
    @schools = School.joins("inner join teachers t on schools.id=t.school_id").select("Schools.*,t.email").
      where("t.types=#{Teacher::TYPES[:SCHOOL]}")
  end
end
