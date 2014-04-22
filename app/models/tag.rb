class Tag < ActiveRecord::Base
  attr_protected :authentications
  belongs_to :school_class

  #获取我的相关tag的id集合
  def self.get_my_tag_ids school_class_id, student_id
    tags = []
    if !student_id.nil? && !school_class_id.nil?
      tags =SchoolClassStudentRalastion.select("tag_id").where("school_class_id = #{school_class_id} and 
                student_id = #{student_id}")
    end
    tags = tags.map{ |t| t.tag_id.present? ? t.tag_id : 0  }
  end
end
