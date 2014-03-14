#encoding: utf-8
class Student < ActiveRecord::Base
  attr_protected :authentications
  STATUS = {:YES => 0, :NO => 1}
  STATUS_NAME = {0 => "正常", 1 => "失效"}
  PER_PAGE = 2
  has_many :school_class_student_ralastions
  has_many :school_classes, :through => :school_class_student_ralastions
  has_many :student_answer_records, :dependent => :destroy
  has_many :user_prop_relations, :dependent => :destroy
  has_many :props, :through => :user_prop_relations
  belongs_to :user
  validates_uniqueness_of :qq_uid

  def self.list_student school_class_id
    sql_student = "SELECT s.id,s.nickname,u.name user_name,u.avatar_url,scsr.created_at,t.name tag_name from
    students s LEFT JOIN users u on s.user_id = u.id
LEFT JOIN school_class_student_ralastions scsr on s.id = scsr.student_id LEFT JOIN tags t on scsr.tag_id = t.id  where
 scsr.school_class_id=?"
    student_school_class = Student.find_by_sql([sql_student,school_class_id])
    recorddetail = RecordDetail.joins("inner join student_answer_records sar on record_details.student_answer_record_id = sar.id").
      select("sar.student_id,record_details.id, record_details.score, record_details.correct_rate").
      where("record_details.is_complete= #{RecordDetail::IS_COMPLETE[:FINISH]}").
      where("sar.student_id in (?)",student_school_class.map(&:id))
    recorddetail_group = recorddetail.group_by{|recordde| recordde[:student_id]}.
      map { |k,v|  {:student_id => k,:correct_rate =>v.inject(0){ |arr, a| arr + a[:correct_rate] }/v.length,
        :score =>v.inject(0){ |arr, a| arr + a[:score] }/v.length  }}
    sql_noanswer_count = "SELECT count1.student_id,(count1.count-IFNULL(count2.count,0)) count from
(SELECT student_id,COUNT(*) count from student_answer_records where school_class_id = ? GROUP BY student_id)
count1 LEFT JOIN (SELECT student_id,COUNT(*) count from student_answer_records where school_class_id = ?
and `status`=#{StudentAnswerRecord::STATUS[:FINISH]} GROUP BY student_id) count2 on
count1.student_id = count2.student_id"
    student_noanswer_counts = StudentAnswerRecord.find_by_sql([sql_noanswer_count,school_class_id,school_class_id])
    archivementsrecord = ArchivementsRecord.where("school_class_id = #{school_class_id}").group_by{|archivement| archivement[:student_id]}
    @student_situations = []
    student_school_class.each do |student|
      student_situation = student.attributes
      student_situation[:student_id] = student.id
      student_situation[:nickname] = student.nickname
      student_situation[:user_name] = student.user_name
      student_situation[:avatar_url] = student.avatar_url
      student_situation[:created_at] = student.created_at
      student_situation[:tag_name] = student.tag_name
      recorddetail_group.each do |recordd_group|
        if student.id.eql?(recordd_group[:student_id])
          student_situation[:correct_rate] = recordd_group[:correct_rate]
          student_situation[:score] = recordd_group[:score]
        end
      end
      student_noanswer_counts.each do |student_noanswer_count|
        if student_noanswer_count.student_id.eql?(student.id)
          student_situation[:unfinished] = student_noanswer_count.count
        end
      end
      archivementsrecord.each do |student_id,archivement|
        if student.id.eql?(student_id)
          archivement.each  do |a|
            case a.archivement_types
            when ArchivementsRecord::TYPES[:PEFECT]
              student_situation[:archive_pefect] = a
            when ArchivementsRecord::TYPES[:ACCURATE]
              student_situation[:archive_accuraie] = a
            when ArchivementsRecord::TYPES[:QUICKLY]
              student_situation[:archive_quickly] = a
            when ArchivementsRecord::TYPES[:EARLY]
              student_situation[:archive_early] = a
            else
              p 2222
            end
          end
        end
      end
      @student_situations << student_situation
    end
    return @student_situations
  end


  def self.student_hastags tag_id,school_class_id
    sql_tag_student = "SELECT s.* from students s INNER JOIN school_class_student_ralastions scsr on s.id=scsr.student_id
where scsr.tag_id = ? and school_class_id = ?"
    @student_hastags = Student.find_by_sql([sql_tag_student,tag_id,school_class_id])
    return @student_hastags
  end
  def self.student_notags school_class_id
    sql_notag_student = "SELECT s.* from students s INNER JOIN school_class_student_ralastions scsr on s.id=scsr.student_id
where scsr.tag_id IS NULL and school_class_id = ?"
    @student_notags = Student.find_by_sql([sql_notag_student,school_class_id])
  end
end
