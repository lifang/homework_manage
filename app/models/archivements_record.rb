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
    else
      archivement.update_attributes(:archivement_score =>
                                        (archivement.archivement_score+10))
    end
  end
end
