#encoding:utf-8
class MainPagesController < ApplicationController
  layout 'tapplication'
  before_filter :sign? 
  before_filter :get_school_class
  def index
    @class_index =-1
    @init_mid = params[:init_mid]
    @condition =  params[:condtions].nil? || params[:condtions].strip=="" ? nil : params[:condtions].strip
    @scclass = SchoolClass.find(@school_class.id)
    @classmates = SchoolClass::get_classmates(@scclass)
    page = @init_mid.nil? || @init_mid.to_i == 0 ? params[:page] : 1
    array = Micropost::get_microposts @scclass,page,@condition,current_user.id
    microposts =array[:details_microposts]
    if @init_mid.nil? || @init_mid.to_i == 0
      @microposts = microposts
    else
      flag = microposts.inject(false){|f,m|
        if m.micropost_id == @init_mid.to_i
          f = true
        end;
        f
      }
      if flag
        @microposts = microposts
        @micropost = Micropost.find_by_id(@init_mid.to_i) if @microposts.any?
        @repiles = (ReplyMicropost::get_microposts @micropost.id,1)[:reply_microposts] if @micropost
      else
        @microposts = Micropost.paginate_by_sql(["select m.id micropost_id, m.user_id, m.user_types, m.content, m.created_at,
                m.reply_microposts_count, u.name, u.avatar_url  from microposts m
                inner join users u on u.id = m.user_id where m.id=?", @init_mid.to_i], :per_page => Micropost::PER_PAGE, :page => 1)
        @micropost = Micropost.find_by_id(@init_mid.to_i) if @microposts.any?
        @repiles = (ReplyMicropost::get_microposts @micropost.id,1)[:reply_microposts] if @micropost
      end
    end
  end

  #删除学生与班级关系
  def delete_student
    student_id = params[:student_id].to_i
    school_class_id = params[:school_class_id].to_i
    student = Student.find_by_id student_id
    if !student.nil?
      sclool_class_and_student_relation = SchoolClassStudentRalastion.
        find_by_school_class_id_and_student_id school_class_id, student_id
      if !sclool_class_and_student_relation.nil?
          base_url = "#{Rails.root}/public"
          #查询答题文件路径
          answer_file_urls = student.student_answer_records.map(&:answer_file_url)
        Student.transaction do
          #查询该学生发布的消息
          microposts_id = Micropost.
              where("user_id = ? and school_class_id = ?", student.user_id, school_class_id)
              .map(&:id)
          #查询该班级的所有消息
          current_class_microposts_id = Micropost.where("school_class_id = ?", school_class_id)
          #删除该学生发布的消息
          Micropost.
              delete_all(["user_id = ? and id in (?)",
                          student.user_id, microposts_id])
          #删除该学生的关注记录
          FollowMicropost.
              delete_all(["user_id = ? and micropost_id in (?)",
                          student.user_id,microposts_id])
          #删除该学生的提示消息
          Message.
            delete_all(["user_id = ? and school_class_id = ?",
                        student.user_id,school_class_id])
          #删除该学生回复过及被回复的子消息
          ReplyMicropost.
            delete_all(["sender_id = ? or reciver_id = ? and micropost_id in (?)",
            student.user_id, student.user_id, current_class_microposts_id])
          #删除答题记录
          StudentAnswerRecord.
              delete_all(["student_id = ? and school_class_id = ?",
                         student.id, school_class_id])
          if sclool_class_and_student_relation.destroy
            answer_file_urls.each do |answer_file_url|
              answer_url = "#{base_url}#{answer_file_url}"
              if File.exist? answer_url
                File.delete answer_url
              end
            end
            @notice = "删除成功！"
          else
            @notice = "删除失败！"
          end
        end
      else
        @notice = "该学生没有加入该班级！"
      end
    else
      @notice = "该学生已被删除或不存在！"
    end
  end
end
