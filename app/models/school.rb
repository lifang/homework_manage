#encoding: utf-8
class School< ActiveRecord::Base
  attr_protected :authentications
  STATUS = {:DELETE => 0,:NORMAL => 1}
  STATUS_NAME = {0=>'已删除',1=>'正常'}
  PER_PAGE = 10
  def self.newpass( len )
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newpass = ""
    1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
    return newpass
  end

  def self.schools_list schools_name=nil,page
    sql_school = "SELECT schools.*,t.email FROM schools inner join teachers t on schools.id=t.school_id
WHERE t.types=#{Teacher::TYPES[:SCHOOL]} "
    if !schools_name.nil?
      sql_school += "and schools.name like '#{schools_name}'"
    end
    @schools = School.paginate_by_sql(sql_school,:per_page => PER_PAGE, :page => page)
  end
end
