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

ActiveRecord::Schema.define(:version => 20140416062938) do

  create_table "admin_messages", :force => true do |t|
    t.integer  "sender_id"
    t.integer  "receiver_id"
    t.string   "content"
    t.boolean  "status"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "admin_messages", ["receiver_id"], :name => "index_admin_messages_on_receiver_id"

  create_table "app_versions", :force => true do |t|
    t.float "c_version"
  end

  add_index "app_versions", ["c_version"], :name => "index_app_versions_on_c_version"

  create_table "archivements_records", :force => true do |t|
    t.integer  "school_class_id"
    t.integer  "student_id"
    t.integer  "archivement_score"
    t.integer  "archivement_types"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "archivements_records", ["school_class_id"], :name => "index_archivements_records_on_school_class_id"
  add_index "archivements_records", ["student_id"], :name => "index_archivements_records_on_student_id"

  create_table "branch_questions", :force => true do |t|
    t.string   "content",      :limit => 1000
    t.integer  "types"
    t.string   "resource_url"
    t.integer  "question_id"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.string   "options",      :limit => 1000
    t.string   "answer"
  end

  add_index "branch_questions", ["question_id"], :name => "index_branch_questions_on_question_id"

  create_table "branch_tags", :force => true do |t|
    t.string   "name"
    t.integer  "teacher_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "branch_tags", ["teacher_id"], :name => "index_branch_tags_on_teacher_id"

  create_table "btags_bque_relations", :force => true do |t|
    t.integer  "branch_question_id"
    t.integer  "branch_tag_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "btags_bque_relations", ["branch_question_id"], :name => "index_btags_bque_relations_on_branch_question_id"
  add_index "btags_bque_relations", ["branch_tag_id"], :name => "index_btags_bque_relations_on_branch_tag_id"

  create_table "card_bags", :force => true do |t|
    t.integer  "school_class_id"
    t.integer  "student_id"
    t.integer  "knowledges_cards_count"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
  end

  add_index "card_bags", ["school_class_id"], :name => "index_card_bags_on_school_class_id"
  add_index "card_bags", ["student_id"], :name => "index_card_bags_on_student_id"

  create_table "card_tag_knowledges_card_relations", :force => true do |t|
    t.integer  "card_tag_id"
    t.integer  "knowledges_card_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "card_tag_knowledges_card_relations", ["card_tag_id"], :name => "index_card_tag_knowledges_card_relations_on_card_tag_id"
  add_index "card_tag_knowledges_card_relations", ["knowledges_card_id"], :name => "index_card_tag_knowledges_card_relations_on_knowledges_card_id"

  create_table "card_tags", :force => true do |t|
    t.string   "name"
    t.integer  "card_bag_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "card_tags", ["card_bag_id"], :name => "index_card_tags_on_card_bag_id"

  create_table "cells", :force => true do |t|
    t.string   "name"
    t.integer  "teaching_material_id"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  create_table "courses", :force => true do |t|
    t.string  "name"
    t.boolean "status", :default => false
  end

  add_index "courses", ["name"], :name => "index_courses_on_name"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.string   "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "episodes", :force => true do |t|
    t.string   "name"
    t.integer  "cell_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "follow_microposts", :force => true do |t|
    t.integer  "user_id"
    t.integer  "micropost_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "follow_microposts", ["micropost_id"], :name => "index_follow_microposts_on_micropost_id"
  add_index "follow_microposts", ["user_id"], :name => "index_follow_microposts_on_user_id"

  create_table "knowledges_cards", :force => true do |t|
    t.integer  "card_bag_id"
    t.integer  "mistake_types"
    t.integer  "branch_question_id"
    t.string   "your_answer"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "knowledges_cards", ["branch_question_id"], :name => "index_knowledges_cards_on_branch_question_id"
  add_index "knowledges_cards", ["card_bag_id"], :name => "index_knowledges_cards_on_card_bag_id"

  create_table "messages", :force => true do |t|
    t.integer  "user_id"
    t.string   "content"
    t.integer  "school_class_id"
    t.integer  "status"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.integer  "sender_id"
    t.integer  "micropost_id"
    t.integer  "reply_micropost_id"
  end

  add_index "messages", ["micropost_id"], :name => "index_messages_on_micropost_id"
  add_index "messages", ["reply_micropost_id"], :name => "index_messages_on_reply_micropost_id"
  add_index "messages", ["school_class_id"], :name => "index_messages_on_school_class_id"
  add_index "messages", ["user_id"], :name => "index_messages_on_user_id"

  create_table "microposts", :force => true do |t|
    t.integer  "user_id"
    t.integer  "user_types"
    t.string   "content"
    t.integer  "school_class_id"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.integer  "reply_microposts_count",  :default => 0
    t.integer  "follow_microposts_count"
  end

  add_index "microposts", ["school_class_id"], :name => "index_microposts_on_school_class_id"
  add_index "microposts", ["user_id"], :name => "index_microposts_on_user_id"

  create_table "props", :force => true do |t|
    t.string   "name"
    t.integer  "types"
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "publish_question_packages", :force => true do |t|
    t.integer  "question_package_id"
    t.integer  "status"
    t.integer  "school_class_id"
    t.string   "question_packages_url"
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.integer  "listening_count"
    t.integer  "reading_count"
    t.integer  "tag_id",                :default => 0
    t.boolean  "is_calc",               :default => false
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
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.integer  "cell_id"
    t.integer  "episode_id"
    t.boolean  "if_shared"
    t.integer  "questions_time"
    t.text     "full_text"
    t.string   "content"
    t.boolean  "if_from_reference",   :default => false
    t.boolean  "status",              :default => true
  end

  add_index "questions", ["question_package_id"], :name => "index_questions_on_question_package_id"

  create_table "record_details", :force => true do |t|
    t.integer  "used_time"
    t.integer  "specified_time"
    t.integer  "question_types"
    t.integer  "correct_rate"
    t.integer  "score"
    t.integer  "is_complete"
    t.integer  "student_answer_record_id"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  add_index "record_details", ["student_answer_record_id"], :name => "index_record_details_on_student_answer_record_id"

  create_table "record_use_props", :force => true do |t|
    t.integer  "user_prop_relation_id"
    t.integer  "branch_question_id"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  add_index "record_use_props", ["branch_question_id"], :name => "index_record_use_props_on_branch_question_id"
  add_index "record_use_props", ["user_prop_relation_id"], :name => "index_record_use_props_on_user_prop_relation_id"

  create_table "reply_microposts", :force => true do |t|
    t.integer  "sender_id"
    t.integer  "sender_types"
    t.string   "content"
    t.integer  "micropost_id"
    t.integer  "reciver_id"
    t.integer  "reciver_types"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.integer  "praise",        :default => 0
  end

  add_index "reply_microposts", ["micropost_id"], :name => "index_reply_microposts_on_micropost_id"
  add_index "reply_microposts", ["reciver_id"], :name => "index_reply_microposts_on_reciver_id"
  add_index "reply_microposts", ["sender_id"], :name => "index_reply_microposts_on_sender_id"

  create_table "sbranch_branch_tag_relations", :force => true do |t|
    t.integer  "share_branch_question_id"
    t.integer  "branch_tag_id"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  add_index "sbranch_branch_tag_relations", ["branch_tag_id"], :name => "index_sbranch_branch_tag_relations_on_branch_tag_id"
  add_index "sbranch_branch_tag_relations", ["share_branch_question_id"], :name => "index_sbranch_branch_tag_relations_on_share_branch_question_id"

  create_table "school_class_student_ralastions", :force => true do |t|
    t.integer  "student_id",      :null => false
    t.integer  "school_class_id", :null => false
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "tag_id"
  end

  create_table "school_class_students_relations", :force => true do |t|
    t.integer  "school_id"
    t.integer  "school_class_id"
    t.integer  "student_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "school_classes", :force => true do |t|
    t.string   "name"
    t.string   "verification_code"
    t.datetime "period_of_validity"
    t.integer  "status"
    t.integer  "teacher_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "teaching_material_id"
  end

  add_index "school_classes", ["teacher_id"], :name => "index_school_classes_on_teacher_id"
  add_index "school_classes", ["teaching_material_id"], :name => "index_school_classes_on_teaching_material_id"

  create_table "schools", :force => true do |t|
    t.string   "name"
    t.integer  "students_count"
    t.boolean  "status",             :default => false
    t.integer  "used_school_counts"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "schools", ["name"], :name => "index_schools_on_name"

  create_table "share_branch_questions", :force => true do |t|
    t.string   "content"
    t.integer  "types"
    t.integer  "share_question_id"
    t.string   "resource_url"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.string   "options",           :limit => 1000
    t.string   "answer"
  end

  add_index "share_branch_questions", ["share_question_id"], :name => "index_share_branch_questions_on_share_question_id"

  create_table "share_questions", :force => true do |t|
    t.string   "name"
    t.integer  "types"
    t.integer  "question_package_type_id"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.integer  "user_id"
    t.integer  "cell_id"
    t.integer  "episode_id"
    t.integer  "referenced_count",         :default => 0
    t.integer  "questions_time"
    t.text     "full_text"
  end

  add_index "share_questions", ["cell_id"], :name => "index_share_questions_on_cell_id"
  add_index "share_questions", ["episode_id"], :name => "index_share_questions_on_episode_id"
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
    t.integer  "average_correct_rate"
    t.integer  "average_complete_rate"
  end

  add_index "student_answer_records", ["publish_question_package_id"], :name => "index_student_answer_records_on_publish_question_package_id"
  add_index "student_answer_records", ["question_package_id"], :name => "index_student_answer_records_on_question_package_id"
  add_index "student_answer_records", ["school_class_id"], :name => "index_student_answer_records_on_school_class_id"
  add_index "student_answer_records", ["student_id"], :name => "index_student_answer_records_on_student_id"

  create_table "student_veri_codes", :force => true do |t|
    t.integer  "code"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "students", :force => true do |t|
    t.string   "nickname"
    t.string   "qq_uid"
    t.integer  "status"
    t.integer  "last_visit_class_id"
    t.integer  "register_status"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.integer  "user_id"
    t.string   "token"
    t.integer  "s_no"
    t.string   "active_code"
    t.boolean  "active_status"
    t.integer  "school_id"
    t.integer  "veri_code"
  end

  add_index "students", ["user_id"], :name => "index_students_on_user_id"
  add_index "students", ["veri_code"], :name => "index_students_on_veri_code"

  create_table "sys_messages", :force => true do |t|
    t.integer  "school_class_id"
    t.integer  "student_id"
    t.string   "content"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "status"
  end

  add_index "sys_messages", ["school_class_id"], :name => "index_sys_messages_on_school_class_id"
  add_index "sys_messages", ["student_id"], :name => "index_sys_messages_on_student_id"

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.integer  "school_class_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "tags", ["school_class_id"], :name => "index_tags_on_school_class_id"

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
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.integer  "user_id"
    t.integer  "last_visit_class_id"
    t.integer  "teaching_material_id"
    t.integer  "school_id"
  end

  add_index "teachers", ["user_id"], :name => "index_teachers_on_user_id"

  create_table "teaching_materials", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.integer  "course_id"
    t.boolean  "status",     :default => true
  end

  create_table "user_prop_relations", :force => true do |t|
    t.integer  "student_id"
    t.integer  "prop_id"
    t.integer  "user_prop_num"
    t.integer  "school_class_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "user_prop_relations", ["prop_id"], :name => "index_user_prop_relations_on_prop_id"
  add_index "user_prop_relations", ["school_class_id"], :name => "index_user_prop_relations_on_school_class_id"
  add_index "user_prop_relations", ["student_id"], :name => "index_user_prop_relations_on_student_id"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "avatar_url"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "verification_codes", :force => true do |t|
    t.integer  "code"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
