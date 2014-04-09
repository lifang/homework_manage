class CreateSchoolClassStudentRelationsAndAddColumnsToStudents < ActiveRecord::Migration
  def change
    create_table :school_class_students_relations do |t|  #系统管理员与学校管理员之间发送消息
      t.integer :school_id
      t.integer :school_class_id
      t.integer :student_id
      t.timestamps
    end

    add_column :students, :s_no, :integer   #学号
    add_column :students, :active_code, :string  #激活码
    add_column :students, :active_status, :boolean   #激活状态
  end

end
