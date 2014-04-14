#encoding: utf-8
require "#{Rails.root}/app/helpers/method_libs_helper"
include MethodLibsHelper
namespace :last_achivement do
  desc "when question package ended_at time is come, get last achievement"  #在作业截止时间到的时候，计算最后一个 “优异” 成就
  task(:auto_generate_customer_types => :environment) do
    SchoolClass.find_each do |school_class|
      publish_question_packages = PublishQuestionPackage.not_calculated(school_class.id) #查询截止日期已过期的，未被统计的任务的id及题包的id
      question_package_ids = publish_question_packages.map(&:question_package_id)
      student_answer_records = RecordDetail.find_by_sql(["SELECT sum(used_time) total_used_time, sum(specified_time) total_specified_time,
sum(score) total_score, avg(correct_rate) avg_correct_rate,
sar.question_package_id, sar.student_id, sar.school_class_id  FROM record_details rd
inner join student_answer_records sar on
rd.student_answer_record_id = sar.id where sar.question_package_id in (?) and sar.school_class_id = ? group by sar.id", question_package_ids, school_class.id])

      grouped_sqrs = student_answer_records.group_by(&:question_package_id)

      grouped_sqrs.each do |question_package_id, datas|
        sort_data = datas.sort{|a,b| b.total_score <=> a.total_score}[0..5]  #抽出前六名
      
        sort_data.each_with_index do |record, index|  #index 作为排名
          index = index+1
          begin
            saved_time = record.total_specified_time - record.total_used_time
            
            saved_time = saved_time > 0 ? saved_time : 0
            time_rate = (saved_time/record.total_specified_time).to_f  #时效性  （规定时间 - 用时）/规定时间
            calculated_score = ((record.avg_correct_rate/100) * 8 + time_rate * 6 + (18/index + 1)).round  # 【优异】成就计算公式  平均正确率*8 + 时效性*6 + (18/排名)

            archivement = ArchivementsRecord.find_by_student_id_and_school_class_id_and_archivement_types(record.student_id,
              school_class.id, ArchivementsRecord::TYPES[:PEFECT].to_i)
            if archivement.nil?
              archivement = ArchivementsRecord.create(:student_id => record.student_id,
                :school_class_id => record.school_class_id,
                :archivement_types => ArchivementsRecord::TYPES[:PEFECT].to_i,
                :archivement_score => calculated_score)
            else
              archivement.update_attributes(:archivement_score => (archivement.archivement_score.to_i + calculated_score))
            end
          rescue Exception => e
            File.open("#{Rails.root}/public/e.log", "a"){|f| f.write "\n question_pack:#{record.question_package_id}----#{e}"}
            next
          else
             p "-----------------------------"
            #获得成就 保存系统消息 并且 发推送
            student = Student.find_by_id record.student_id
            #额外参数
            extras_hash = {:type => Student::PUSH_TYPE[:sys_message], :class_id => school_class.id, :class_name => school_class.name, :student_id => student.id}
            content = "恭喜您获得成就“#{ArchivementsRecord::TYPES_NAME[ArchivementsRecord::TYPES[:PEFECT]]}”"
            save_sys_message(student, content, extras_hash, school_class)
          end
        end
      end

      publish_question_packages.update_all(is_calc:true)  #已经计算过优异的，更新字段
    end
  end

end