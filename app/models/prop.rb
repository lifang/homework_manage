class Prop < ActiveRecord::Base
  attr_protected :authentications

  #获取道具数量
  def self.get_prop_num school_class_id, student_id
    sql_str = "select p.types, upr.user_prop_num from props p left join user_prop_relations upr
      on p.id = upr.prop_id where upr.school_class_id = #{school_class_id}
      and upr.student_id = #{student_id}"
    props = Prop.find_by_sql sql_str
    props_details = []
    props.each do |e|
      props_details << {:types => e.types, :number => e.user_prop_num}
    end
    props_details
  end
end
