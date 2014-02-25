#encoding: utf-8
class RecordDetail < ActiveRecord::Base
  attr_protected :authentications
  belongs_to :student_answer_record
  STATUS = {:DEALING => 0, :FINISH => 1}
  STATUS_NAME = {0 => "进行中", 1 => "完成"}

end
