class TeachingMaterial < ActiveRecord::Base
  require 'roo'
  attr_protected :authentications
  has_many :cells, :dependent => :destroy
  has_many :school_classes, :dependent => :nullify
  belongs_to :course

  STATUS = {:DELETED => 0, :NORMAL => 1}  #状态 0已删除 1正常

  def self.upload_xls course_id, teaching_materia_id, cell_episode_xls
    path = upload_xls_file(course_id, teaching_materia_id, cell_episode_xls)
    status = 1
    if path == ""
      status = 2
    else
      type = path.split(".").reverse[0]
      begin
        if type == "xls"
          s = Roo::Excel.new(path)
        elsif type == "xlsx"
          s = Roo::Excelx.new(path)
        end
        s.default_sheet = s.sheets.first
        s.each_with_index do |row, index|
          if index != 0
            if row[0].nil? == false && row[0] != ""
              cell = Cell.new(:name => "#{row[0]}", :teaching_material_id => teaching_materia_id)
              if cell.save
                row[1..row.length-1].each do |r|
                  Episode.create(:name => "#{r}", :cell_id => cell.id) if r && r != ""
                end if row.length > 1
              end
            end
          end
        end
      rescue
        status = 2
      end
    end
    return status
  end    


  def self.upload_xls_file course_id, teaching_materia_id, cell_episode_xls
    root_path = "#{Rails.root}/public/"
    dirs = ["/cells_xls", "/#{course_id}", "/#{teaching_materia_id}"]
    ori_file_name = cell_episode_xls.original_filename
    file_name = "#{dirs.join}/#{teaching_materia_id}.#{ori_file_name.split(".").reverse[0]}"
    path = ""
    begin
      dirs.each_with_index {|d, index| Dir.mkdir(root_path + dirs[0..index].join) unless File.directory?(root_path + dirs[0..index].join)}
      File.open(root_path+ file_name, "wb") { |i| i.write(cell_episode_xls.read) }    #存入表格xls文件
      path = root_path+ file_name
    rescue
      path = ""
    end
    return path
  end

end
