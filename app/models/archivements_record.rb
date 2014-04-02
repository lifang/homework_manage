#encoding: utf-8
class ArchivementsRecord < ActiveRecord::Base
  attr_protected :authentications
  TYPES = {:PEFECT => 0, :ACCURATE => 1, :QUICKLY => 2, :EARLY => 3}
  TYPES_NAME = {0 => "优异", 1 => "精准", 2 => "迅速", 3 => "捷足"}

  def self.update_archivements student, school_class, archivement_types
    archivement =  ArchivementsRecord
    .find_by_student_id_and_school_class_id_and_archivement_types(student.id,
      school_class.id, archivement_types)
    if archivement.nil?
      archivement = ArchivementsRecord.create(:student_id => student.id,
        :school_class_id => school_class.id,
        :archivement_types => archivement_types,
        :archivement_score => 10)
      unless archivement.archivement_score.nil?
        if archivement.archivement_score%100 == 0
          if archivement.archivement_types==ArchivementsRecord::TYPES[:QUICKLY]
            add_prop_get_archivement student.id,Prop::TYPES[:Reduce_time],school_class
          end
          if archivement.archivement_types==ArchivementsRecord::TYPES[:ACCURATE]
            add_prop_get_archivement student.id,Prop::TYPES[:Show_corret_answer],school_class
          end
        end
      end
    else
      archivement.update_attributes(:archivement_score =>
          (archivement.archivement_score+10))
    end
    content = "恭喜您获得成就“#{TYPES_NAME[archivement_types]}”"
    extras_hash = {:type => Student::PUSH_TYPE[:sys_message]}
    SysMessage.create(school_class_id:school_class.id,
      student_id:student.id,
      content:content,
      status:0)
    android_and_ios_push(school_class,content,extras_hash)
  end
  
  #获得成就时加道具
  def self.add_prop_get_archivement student_id,prop_types,school_class
    student_prop = UserPropRelation.
      find_by_student_id_and_prop_id_and_school_class_id(student_id,prop_types,school_class.id)
    if student_prop
      student_prop.update_attribute(:user_prop_num,student_prop.user_prop_num+2);
    else
      UserPropRelation.create(student_id:student_id,
        user_prop_num:2,
        school_class_id:school_class.id,
        prop_id:prop_types)
    end

  end

end
