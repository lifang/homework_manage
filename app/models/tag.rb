class Tag < ActiveRecord::Base
  attr_protected :authentications

  #获取我的相关tag的id集合
  def self.get_my_tag_ids school_class_id=nil, student_id=nil
    tags = nil
    if !student_id.nil? && !school_class_id.nil?
      my_tag_sql = "select t.id from tags t left join tag_student_relations ts
        on t.id = ts.tag_id where t.school_class_id = #{school_class_id}
        and ts.student_id = #{student_id}"
      tags = Tag.find_by_sql my_tag_sql
    end
    tags.map!(&:id) if !tags.nil?
    tags
  end
end
