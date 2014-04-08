class Course < ActiveRecord::Base
  has_many :teaching_materials
  STATUS = {:DELETED => 0, :NORMAL => 1}  #状态 0已删除 1正常

  PER_PAGE = 5
end
