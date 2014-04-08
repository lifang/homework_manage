class TeachingMaterial < ActiveRecord::Base
  require 'spreadsheet'
  attr_protected :authentications
  has_many :cells, :dependent => :destroy
  has_many :school_classed, :dependent => :nullify

  CELL_AND_EPISODE_XLS_path = "#{Rails.root}/"
  STATUS = {:DELETED => 0, :NORMAL => 1}  #状态 0已删除 1正常

  def self.upload_xls teaching_materia_id, cell_episode_xls
    Spreadsheet.open cell_episode_xls do |book|  
      sheet = book.worksheet 0
      str = ""
      sheet.each_with_index do |row,index|
#        if index != 0
#          cell = row[0]
#          str += "#{cell}=>"
#        end
p row.length
      end
    end
  end


end
