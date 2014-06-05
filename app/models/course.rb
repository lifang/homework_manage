class Course < ActiveRecord::Base
   attr_protected :authentications
   has_many :teaching_materials
  STATUS = {:DELETED => 0, :NORMAL => 1}  #状态 0已删除 1正常
  TYPES = {:dictation => 1, :full => 0}  #听写用的课程， 还是所有都用的
  PER_PAGE = 5
  scope :normal, :conditions =>  {:status => STATUS[:NORMAL] }
  scope :dictation, :conditions =>  {:types => TYPES[:dictation] }
end
