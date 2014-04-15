#encoding: utf-8
class Question < ActiveRecord::Base
  attr_protected :authentications
  belongs_to :question_package
  has_many :branch_questions, :dependent => :destroy

  IF_SHARED = {:YES => 1, :NO => 0}    #是否分享
  IF_FROM_REFER = {:YES => 1, :NO => 0}  #是否是引用来的
  TYPE_NAME_ARR = ["listening", "reading", "time_limit", "selecting", "lining", "cloze", "sort"]
  TYPES = {:LISTENING => 0, :READING => 1, :TIME_LIMIT => 2, :SELECTING => 3, :LINING => 4, :CLOZE => 5, :SORT => 6 }
  TYPES_TITLE = {0 => "listening", 1 => "reading", 2 => "time_limit", 3 => "selecting", 4 => "lining", 5 => "cloze", 6 => "sort" }
  TYPES_NAME = {0 => "听写", 1 => "朗读",  2 => "十速挑战", 3 => "选择", 4 => "连线", 5 => "完型填空", 6 => "排序"}
  RECORD_TYPES = {"listening" => 0, "reading" => 1, "time_limit" => 2, "selecting" => 3, "lining" => 4, "cloze" => 5, "sort" => 6 }
  TYPE_NAME_ARR.each do |type|
    scope type.to_sym, :conditions => { :types => TYPES[type.upcase.to_sym] }
  end
  STATUS = {:NORMAL => 1, :DELETED => 0}  #状态 1正常 0删除
  PER_PAGE = 10
  #查询一个题包下的所有题目
  def self.get_all_questions question_package
    all_questions = []
    sql_str = "SELECT q.id, q.types, q.created_at,q.questions_time,q.full_text, b.id branch_question_id,
       b.content, b.resource_url, b.options, b.answer FROM questions q left join branch_questions b
       on q.id = b.question_id where q.question_package_id =#{question_package.id}
       and b.id is not null"
    all_questions = Question.find_by_sql sql_str
  end


  def self.sava_select_qu check_select,select_value1,select_value2,select_value3,select_value4
    answer = ""
    options = select_value1 + ";||;"+ select_value2 +";||;"+ select_value3 + ";||;" + select_value4
    if check_select
      check_select.each do |check|
        case check.to_i
        when 1
          if answer.blank?
            answer += select_value1
          else
            answer += ';||;' + select_value1
          end
        when 2
          if answer.blank?
            answer += select_value2
          else
            answer += ';||;' + select_value2
          end
        when 3
          if answer.blank?
            answer += select_value3
          else
            answer += ';||;' + select_value3
          end
        when 4
          if answer.blank?
            answer += select_value4
          else
            answer += ';||;' + select_value4
          end
        else
          p 2222
        end
      end
    end
    info = {:answer=>answer,:options=>options}
  end

  def self.get_has_reading_and_listening_branch ques
    branch_ques = {}
    if ques.present?
      ques = ques.group_by {|q| q.types} 
      reading_que_id = ques[Question::TYPES[:READING]].present? ? ques[Question::TYPES[:READING]].map { |q|  q.id} : []
      listening_que_id = ques[Question::TYPES[:LISTENING]].present? ? ques[Question::TYPES[:LISTENING]].map { |q|  q.id} : []
      reading_and_listening_que_id = reading_que_id + listening_que_id
      if reading_and_listening_que_id.present?
        branch_ques = BranchQuestion
        .select("id,question_id,content, resource_url")
        .where(["question_id in (?)", reading_and_listening_que_id])
        branch_ques = branch_ques.group_by {|bq| bq.question_id}
      end  
    end
    branch_ques 
  end

  def self.get_questions question_package_ids, page, cell_id=nil, eposode_id=nil, type=nil
    if question_package_ids && question_package_ids.any?
      sqls = ["select q.*,c.name cname, e.name ename from questions q inner join cells c on q.cell_id=c.id
      left join episodes e on q.episode_id=e.id where q.status=? and q.question_package_id in (?)",
        Question::STATUS[:NORMAL], question_package_ids]
      if cell_id
        sqls[0] += " and q.cell_id=?"
        sqls << cell_id
      end
      if eposode_id
        sqls[0] += " and q.episode_id=?"
        sqls << eposode_id
      end
      if type
        sqls[0] += " and q.types=?"
        sqls << type
      end
      questions = Question.paginate_by_sql(sqls, :page => page ||=1, :per_page => Question::PER_PAGE)
      return questions
    else
      return nil
    end
  end

end
