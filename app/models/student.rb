#encoding: utf-8
class Student < ActiveRecord::Base
  require 'will_paginate/array'
  attr_protected :authentications
  STATUS = {:YES => 0, :NO => 1}
  STATUS_NAME = {0 => "正常", 1 => "失效"}
  PUSH_TYPE_NAME = {0 => "系统消息", 1 => "问答回复", 2 => "发布作业"}
  PUSH_TYPE = {:sys_message => 0, :q_and_a => 1, :publish_question => 2}
  PER_PAGE = 2
  has_many :school_class_student_ralastions
  has_many :school_classes, :through => :school_class_student_ralastions
  has_many :student_answer_records, :dependent => :destroy
  has_many :user_prop_relations, :dependent => :destroy
  has_many :props, :through => :user_prop_relations
  belongs_to :user
  validates_uniqueness_of :qq_uid

  def self.list_student page,school_class_id
    sql_student = "SELECT s.id,s.nickname,u.name user_name,u.avatar_url,scsr.created_at,t.name tag_name from
    students s LEFT JOIN users u on s.user_id = u.id
LEFT JOIN school_class_student_ralastions scsr on s.id = scsr.student_id LEFT JOIN tags t on scsr.tag_id = t.id  where
 scsr.school_class_id=?"
    student_school_class = Student.paginate_by_sql([sql_student,school_class_id],:per_page => 2, :page => page)
    #    正确率
    recorddetail = RecordDetail.joins("inner join student_answer_records sar on record_details.student_answer_record_id = sar.id").
      select("sar.student_id,record_details.id,  avg(record_details.correct_rate) correct_rate ").
      where("record_details.is_complete= #{RecordDetail::IS_COMPLETE[:FINISH]}").
      where("sar.student_id in (?)",student_school_class.map(&:id)).group("sar.student_id")
    #未交作业次数
    sql_public_count = "SELECT count(*) count FROM publish_question_packages WHERE school_class_id = ?"
    sql_comp_count = "SELECT student_id,count(*) count FROM student_answer_records WHERE status=#{StudentAnswerRecord::STATUS[:FINISH]}
                      and school_class_id = ? GROUP BY student_id"
    count_public = PublishQuestionPackage.find_by_sql([sql_public_count,school_class_id]).first
    count_public_num = count_public.present? ? count_public.count : 0
    count_complishs = StudentAnswerRecord.find_by_sql([sql_comp_count,school_class_id])
    #成就
    archivementsrecord = ArchivementsRecord.where("school_class_id = #{school_class_id}").group_by{|archivement| archivement[:student_id]}
    student_situations = []
    student_school_class.each do |student|
      student_situation = student.attributes
      student_situation[:student_id] = student.id
      student_situation[:nickname] = student.nickname
      student_situation[:user_name] = student.user_name
      student_situation[:avatar_url] = student.avatar_url
      student_situation[:created_at] = student.created_at
      student_situation[:tag_name] = student.tag_name
      recorddetail.each do |record|
        if student.id.eql?(record.student_id)
          student_situation[:correct_rate] = record.correct_rate
        end
      end
      student_situation[:correct_rate] = student_situation[:correct_rate].nil? ? 0 : student_situation[:correct_rate]
      count_complishs.each do |count_complish|
        if count_complish.student_id.eql?(student.id)
          student_situation[:unfinished] = count_public_num - count_complish.count
        end
      end
      student_situation[:unfinished] = student_situation[:unfinished].nil? ? count_public_num : student_situation[:unfinished]
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
      student_situations << student_situation
    end
    return info = {:student_situations =>student_situations,:student_school_class=>student_school_class}
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
