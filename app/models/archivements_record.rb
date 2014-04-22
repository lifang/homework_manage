#encoding: utf-8
class ArchivementsRecord < ActiveRecord::Base
  attr_protected :authentications
  TYPES = {:PEFECT => 0, :ACCURATE => 1, :QUICKLY => 2, :EARLY => 3,:KUDOS => 4}
  TYPES_NAME = {0 => "优异", 1 => "精准", 2 => "迅速", 3 => "捷足",4 => '牛气'}
  LEVEL_SCORE = 100

  def self.update_archivements student, school_class, archivement_types
    archivement =  ArchivementsRecord
    .find_by_student_id_and_school_class_id_and_archivement_types(student.id,
      school_class.id, archivement_types)
    if archivement.nil?
      archivement = ArchivementsRecord.create(:student_id => student.id,
        :school_class_id => school_class.id,
        :archivement_types => archivement_types,
        :archivement_score => 10)
    else
      archivement.update_attributes(:archivement_score =>
          (archivement.archivement_score.to_i+10))
    end

    #额外参数
    extras_hash = {:type => Student::PUSH_TYPE[:sys_message], :class_id => school_class.id, :class_name => school_class.name, :student_id => student.id}

    #获得成就 保存系统消息 并且 发推送
    content = "恭喜你获得了“#{TYPES_NAME[archivement_types]}”成就的10个积分"
    save_sys_message(student, content, extras_hash, school_class)

    #升级 保存系统消息，并推送
    if archivement && archivement.archivement_score.present?
      if archivement.archivement_score%100 == 0

        content = "恭喜您! #{TYPES_NAME[archivement.archivement_types]}成就升到“#{archivement.archivement_score/100}”级了"
        save_sys_message(student, content, extras_hash, school_class)
        
        if archivement.archivement_types==ArchivementsRecord::TYPES[:QUICKLY]  #迅速
          add_prop_get_archivement student.id,school_class #升级， 送道具
        end

        if archivement.archivement_types==ArchivementsRecord::TYPES[:ACCURATE]  #精准
          add_prop_get_archivement student.id,school_class  #升级， 送道具
#          add_prop_get_archivement student.id,Prop::TYPES[:Reduce_time],school_class
#          add_prop_get_archivement student.id,Prop::TYPES[:Show_corret_answer],school_class
        end

      end
    end
  end
  
  #获得成就时加道具
  def self.add_prop_get_archivement student_id,school_class
    student_props = UserPropRelation.where(:student_id => student_id, :school_class_id => school_class.id)
    if student_props
      student_props.each{|upr| upr.update_attribute(:user_prop_num, upr.user_prop_num.to_i + 2)}
    else
      Prop.find_each do |prop|
        UserPropRelation.create(student_id:student_id,
          user_prop_num:2,
          school_class_id:school_class.id,
          prop_id:prop.id)
      end

    end

  end

end
