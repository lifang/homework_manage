# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140117015516) do

  create_table "branch_questions", :force => true do |t|
    t.string   "content"
    t.integer  "types"
    t.string   "resource_url"
    t.integer  "question_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "branch_questions", ["question_id"], :name => "index_branch_questions_on_question_id"

  create_table "follow_microposts", :force => true do |t|
    t.integer  "user_id"
    t.integer  "micropost_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "follow_microposts", ["micropost_id"], :name => "index_follow_microposts_on_micropost_id"
  add_index "follow_microposts", ["user_id"], :name => "index_follow_microposts_on_user_id"

  create_table "messages", :force => true do |t|
    t.integer  "user_id"
    t.string   "content"
    t.integer  "school_class_id"
    t.integer  "status"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "sender_id"
  end

  add_index "messages", ["school_class_id"], :name => "index_messages_on_school_class_id"
  add_index "messages", ["user_id"], :name => "index_messages_on_user_id"

  create_table "microposts", :force => true do |t|
    t.integer  "user_id"
    t.integer  "user_types"
    t.string   "content"
    t.integer  "school_class_id"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.integer  "reply_microposts_count", :default => 0
  end

  add_index "microposts", ["school_class_id"], :name => "index_microposts_on_school_class_id"
  add_index "microposts", ["user_id"], :name => "index_microposts_on_user_id"

  create_table "publish_question_packages", :force => true do |t|
    t.integer  "question_package_id"
    t.integer  "status"
    t.integer  "school_class_id"
    t.string   "question_packages_url"
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.integer  "listening_count"
    t.integer  "reading_count"
  end

  add_index "publish_question_packages", ["question_package_id"], :name => "index_publish_question_packages_on_question_package_id"
  add_index "publish_question_packages", ["school_class_id"], :name => "index_publish_question_packages_on_school_class_id"

  create_table "question_package_types", :force => true do |t|
    t.string   "name"
    t.string   "teaching_material_name"
    t.string   "teaching_material_isbn"
    t.string   "teaching_material_pulisher"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  create_table "question_packages", :force => true do |t|
    t.string   "name"
    t.integer  "school_class_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "question_packages", ["school_class_id"], :name => "index_question_packages_on_school_class_id"

  create_table "questions", :force => true do |t|
    t.string   "name"
    t.integer  "types"
    t.integer  "question_package_id"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "questions", ["question_package_id"], :name => "index_questions_on_question_package_id"

  create_table "reply_microposts", :force => true do |t|
    t.integer  "sender_id"
    t.integer  "sender_types"
    t.string   "content"
    t.integer  "micropost_id"
    t.integer  "reciver_id"
    t.integer  "reciver_types"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "reply_microposts", ["micropost_id"], :name => "index_reply_microposts_on_micropost_id"
  add_index "reply_microposts", ["reciver_id"], :name => "index_reply_microposts_on_reciver_id"
  add_index "reply_microposts", ["sender_id"], :name => "index_reply_microposts_on_sender_id"

  create_table "school_class_student_ralastions", :force => true do |t|
    t.integer  "student_id"
    t.integer  "school_class_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "school_class_student_ralastions", ["school_class_id"], :name => "index_school_class_student_ralastions_on_class_id"
  add_index "school_class_student_ralastions", ["student_id"], :name => "index_school_class_student_ralastions_on_student_id"

  create_table "school_classes", :force => true do |t|
    t.string   "name"
    t.string   "verification_code"
    t.datetime "period_of_validity"
    t.integer  "status"
    t.string   "teacher_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "school_classes", ["teacher_id"], :name => "index_school_classes_on_teacher_id"

  create_table "share_branch_questions", :force => true do |t|
    t.string   "content"
    t.integer  "types"
    t.integer  "share_question_id"
    t.string   "resource_url"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "share_branch_questions", ["share_question_id"], :name => "index_share_branch_questions_on_share_question_id"

  create_table "share_questions", :force => true do |t|
    t.string   "name"
    t.integer  "types"
    t.integer  "question_package_type_id"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  add_index "share_questions", ["question_package_type_id"], :name => "index_share_questions_on_question_package_type_id"

  create_table "student_answer_records", :force => true do |t|
    t.integer  "student_id"
    t.integer  "question_package_id"
    t.integer  "status"
    t.string   "answer_file_url"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.integer  "publish_question_package_id"
    t.integer  "school_class_id"
    t.integer  "listening_answer_count"
    t.integer  "reading_answer_count"
  end

  add_index "student_answer_records", ["publish_question_package_id"], :name => "index_student_answer_records_on_publish_question_package_id"
  add_index "student_answer_records", ["question_package_id"], :name => "index_student_answer_records_on_question_package_id"
  add_index "student_answer_records", ["school_class_id"], :name => "index_student_answer_records_on_school_class_id"
  add_index "student_answer_records", ["student_id"], :name => "index_student_answer_records_on_student_id"

  create_table "students", :force => true do |t|
    t.string   "nickname"
    t.string   "alias_name"
    t.string   "qq_uid"
    t.integer  "status"
    t.integer  "last_visit_class_id"
    t.integer  "register_status"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.integer  "user_id"
  end

  add_index "students", ["user_id"], :name => "index_students_on_user_id"

  create_table "task_messages", :force => true do |t|
    t.integer  "school_class_id"
    t.string   "content"
    t.datetime "period_of_validity"
    t.integer  "status"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.integer  "publish_question_package_id"
  end

  add_index "task_messages", ["publish_question_package_id"], :name => "index_task_messages_on_publish_question_package_id"
  add_index "task_messages", ["school_class_id"], :name => "index_task_messages_on_school_class_id"

  create_table "teachers", :force => true do |t|
    t.string   "password"
    t.string   "email"
    t.integer  "status"
    t.integer  "types"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "user_id"
  end

  add_index "teachers", ["user_id"], :name => "index_teachers_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "avatar_url"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
