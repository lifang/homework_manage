class Tag < ActiveRecord::Base
  attr_protected :authentications
  belongs_to :school_class

  #获取我的相关tag的id集合
  def self.get_my_tag_ids school_class_id, student_id
    tags = nil
    if !student_id.nil? && !school_class_id.nil?
      my_tag_sql = "select s.tag_id from school_class_student_ralastions s
        where s.school_class_id = #{school_class_id}
        and s.student_id = #{student_id} and tag_id is not null"
      tags = Tag.find_by_sql my_tag_sql
    end
    tags = [] if tags.nil?
    tags.map!(&:id) if !tags.nil?
    p tags
    
    tags
    p tags
  end
end
