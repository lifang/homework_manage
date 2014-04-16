#encoding: utf-8
class Student < ActiveRecord::Base
  require 'roo'
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
  validates_uniqueness_of :qq_uid, :allow_nil => true
  PER_PAGE = 10
  ACTIVE_STATUS = {:YES => 1, :NO => 0} #是否激活 1已激活 0未激活
  def self.list_student page,school_class_id
    sql_student = "SELECT s.id,s.nickname,u.name user_name,u.avatar_url,scsr.created_at,t.name tag_name from
    students s LEFT JOIN users u on s.user_id = u.id
LEFT JOIN school_class_student_ralastions scsr on s.id = scsr.student_id LEFT JOIN tags t on scsr.tag_id = t.id  where
 scsr.school_class_id=? and s.status!=#{STATUS[:NO]}"
    student_school_class = Student.paginate_by_sql([sql_student,school_class_id],:per_page => PER_PAGE, :page => page)
    #    正确率
    recorddetail = RecordDetail.joins("inner join student_answer_records sar on record_details.student_answer_record_id = sar.id").
      select("sar.student_id,record_details.id,  avg(record_details.correct_rate) correct_rate ").
      where("sar.student_id in (?)",student_school_class.map(&:id)).where("sar.school_class_id=#{school_class_id}").group("sar.student_id").
      group_by{|record| record.student_id}
    #未交作业次数
    sql_public_count = "SELECT count(*) count_all FROM publish_question_packages WHERE school_class_id = ?"
    sql_comp_count = "SELECT student_id,count(*) count_pack FROM student_answer_records WHERE status=#{StudentAnswerRecord::STATUS[:FINISH]}
                      and school_class_id = ? GROUP BY student_id"
    count_public = PublishQuestionPackage.find_by_sql([sql_public_count,school_class_id]).first
    count_public_num = count_public.present? ? count_public.count_all : 0
    count_complishs = StudentAnswerRecord.find_by_sql([sql_comp_count,school_class_id]).group_by{|count_complish| count_complish.student_id}
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
      student_situation[:correct_rate] =  recorddetail[student.id].nil? ? 0 : recorddetail[student.id][0].correct_rate
      student_situation[:unfinished] = count_complishs[student.id].nil? ? count_public_num : count_public_num - count_complishs[student.id][0].count_pack
      if archivementsrecord[student.id].present?
        archivementsrecord[student.id].each  do |a|
          case a.archivement_types
          when ArchivementsRecord::TYPES[:PEFECT]
            student_situation[:archive_pefect] = a
          when ArchivementsRecord::TYPES[:ACCURATE]
            student_situation[:archive_accuraie] = a
          when ArchivementsRecord::TYPES[:QUICKLY]
            student_situation[:archive_quickly] = a
          when ArchivementsRecord::TYPES[:EARLY]
            student_situation[:archive_early] = a
          when ArchivementsRecord::TYPES[:KUDOS]
            student_situation[:haspraise] = a
          else
            p 2222
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

  def self.upload_student_list_xls school_id, student_list_xls #解析表格文件并且存入数据库
    file_path, max_code = upload_student_list_xls_file(school_id, student_list_xls)
    status = 1
    unique_s_no = []
    unique_str = ""
    if file_path == ""
      status = 0
    else
      file_type = file_path.split(".").reverse[0]
      begin
        if file_type == "xls"
          s = Roo::Excel.new(file_path)
        elsif file_type == "xlsx"
          s = Roo::Excelx.new(file_path)
        end
        s.default_sheet = s.sheets.first  #默认第一页卡(sheet1)
        s.each_with_index do |row, index|
          if index != 0
            s_no_ele = row[1].class.to_s == "String" ? row[1] : "#{row[1].to_i}"
            unique_s_no << s_no_ele
          end
        end
        unique_stus = Student.where(["school_id=? and s_no in (?)", school_id, unique_s_no])
        if unique_stus.length > 0
          status = -1
          unique_str = unique_stus.map(&:s_no).join(", ")
        end
        if status == 1
          s.each_with_index do |row, index|
            if index != 0
              if row[0] && row[1]
                user = User.create(:name => row[0])
                student = Student.create!(:nickname => row[0], :status => Student::STATUS[:YES], :user_id => user.id,
                  :s_no => row[1].class.to_s == "String" ? row[1] : "#{row[1].to_i}",
                  :active_status => ACTIVE_STATUS[:NO], :school_id => school_id, :veri_code => max_code)
                str = ""
                if student.id < 10
                  str = "00000#{student.id}"
                elsif student.id >= 10 && student.id < 100
                  str = "0000#{student.id}"
                elsif student.id >= 100 && student.id < 1000
                  str = "000#{student.id}"
                elsif student.id >= 1000 && student.id < 10000
                  str = "00#{student.id}"
                elsif student.id >= 10000 && student.id < 100000
                  str = "0#{student.id}"
                else
                  str = "#{student.id}"
                end
                student.update_attribute("active_code", "#{max_code}#{str}")
              end
            end
          end
          StudentVeriCode.create(:code => max_code)
        end
      rescue Exception => e
        File.delete(file_path) if File.exist?(file_path)
        status = 0
      end
    end
    return [status, max_code, unique_str]
  end

  def self.upload_student_list_xls_file school_id, student_list_xls  #上传学生表格文件到服务器
    root_path = "#{Rails.root}/public/"
    ori_file_name = student_list_xls.original_filename
    mc = StudentVeriCode.find_by_sql(["select max(code) m_code from student_veri_codes"]).first
    if mc.m_code.nil?
      max_code = 1001
    else
      max_code = mc.m_code + 1
    end
    dirs = ["/students_xls", "/#{school_id}", "/#{max_code}"]
    file_name = "#{dirs.join}/#{max_code}.#{ori_file_name.split(".").reverse[0]}"
    path = ""
    begin
      dirs.each_with_index{|d,index| Dir.mkdir(root_path + dirs[0..index].join) unless File.directory?(root_path + dirs[0..index].join)}
      File.open(root_path+ file_name, "wb") { |i| i.write(student_list_xls.read) }    #存入表格xls文件
      path = root_path+ file_name
    rescue Exception => e
      path = ""
    end
    return [path, max_code]
  end

  def self.make_student_list_xls_report students    #生成学生激活码表格单
    xls_report = StringIO.new
    Spreadsheet.client_encoding = "UTF-8"
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet :name => "学生激活码清单"  #页卡
    sheet1.row(0).concat %w{姓名 学号 激活码}
    students.each_with_index do |s, index|
      sheet1.row(index + 1).concat ["#{s.nickname}", "#{s.s_no}", "#{s.active_code}"]
    end
    book.write xls_report
    xls_report.string
  end
end
