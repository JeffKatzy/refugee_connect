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

ActiveRecord::Schema.define(:version => 20140829203508) do

  create_table "add_appointment_id_to_call_to_users", :force => true do |t|
    t.integer  "appointment_id"
    t.integer  "call_to_users"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "appointments", :force => true do |t|
    t.string   "status"
    t.integer  "start_page"
    t.integer  "finish_page"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.datetime "began_at"
    t.datetime "ended_at"
    t.datetime "scheduled_for"
    t.integer  "tutor_id"
    t.integer  "tutee_id"
    t.integer  "match_id"
    t.integer  "lesson_id"
  end

  create_table "assignments", :force => true do |t|
    t.text     "instructions"
    t.integer  "lesson_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "attachinary_files", :force => true do |t|
    t.integer  "attachinariable_id"
    t.string   "attachinariable_type"
    t.string   "scope"
    t.string   "public_id"
    t.string   "version"
    t.integer  "width"
    t.integer  "height"
    t.string   "format"
    t.string   "resource_type"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  add_index "attachinary_files", ["attachinariable_type", "attachinariable_id", "scope"], :name => "by_scoped_parent"

  create_table "availabilities", :force => true do |t|
    t.integer  "user_id"
    t.integer  "per_week"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.text     "schedule_hash"
  end

  create_table "availability_managers", :force => true do |t|
    t.integer  "user_id"
    t.integer  "per_week"
    t.text     "schedule_hash"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "available_times", :force => true do |t|
    t.integer  "user_id"
    t.datetime "time_available"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "weekday"
    t.string   "hour"
    t.text     "schedule"
  end

  create_table "available_users", :force => true do |t|
    t.integer  "user_id"
    t.datetime "from"
    t.datetime "to"
    t.boolean  "available"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "book_pages", :force => true do |t|
    t.string   "title"
    t.integer  "page_number"
    t.string   "image"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "bookpages", :force => true do |t|
    t.string   "title"
    t.integer  "page_number"
    t.string   "image"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "assignment_id"
  end

  create_table "call_to_users", :force => true do |t|
    t.integer  "tutor_id"
    t.integer  "tutee_id"
    t.datetime "begin_time"
    t.datetime "end_time"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "appointment_id"
  end

  create_table "comments", :force => true do |t|
    t.text     "comment_text"
    t.integer  "tutor_id"
    t.integer  "user_assignment_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.integer  "appointment_id"
    t.integer  "tutee_id"
    t.integer  "bookpage_id"
  end

  create_table "confirmations", :force => true do |t|
    t.integer  "user_id"
    t.integer  "specific_opening_id"
    t.boolean  "confirmed"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "facebook_users", :force => true do |t|
    t.string   "uid"
    t.string   "provider"
    t.string   "oauth_token"
    t.string   "profile_picture"
    t.string   "oauth_expires_at"
    t.integer  "user_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "facebooks", :force => true do |t|
    t.string   "add_facebook_info_to_users"
    t.string   "uid"
    t.string   "oauth_token"
    t.string   "profile_picture"
    t.datetime "oauth_expires_at"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.integer  "user_id"
    t.string   "provider"
  end

  create_table "lessons", :force => true do |t|
    t.text     "name"
    t.text     "description"
    t.text     "objectives"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "start_page"
    t.integer  "finish_page"
  end

  create_table "locations", :force => true do |t|
    t.integer  "user_id"
    t.string   "address"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "country"
  end

  create_table "matches", :force => true do |t|
    t.integer  "tutor_id"
    t.integer  "tutee_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.datetime "match_time"
    t.boolean  "available"
  end

  create_table "openings", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "day_open"
    t.datetime "time"
    t.string   "time_open"
  end

  create_table "pages", :force => true do |t|
    t.integer  "page_number"
    t.string   "lesson"
    t.string   "book"
    t.text     "image"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "photos", :force => true do |t|
    t.integer  "user_id"
    t.text     "url"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.integer  "tweet_id",         :limit => 8
    t.datetime "tweet_created_at"
  end

  create_table "profile_infos", :force => true do |t|
    t.integer  "user_id"
    t.string   "age"
    t.text     "interests"
    t.text     "english_focus"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "reminder_texts", :force => true do |t|
    t.integer  "appointment_id"
    t.datetime "time"
    t.integer  "user_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "category"
  end

  create_table "schedules", :force => true do |t|
    t.integer  "user_id"
    t.text     "schedule"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "specific_openings", :force => true do |t|
    t.integer  "user_id"
    t.integer  "opening_id"
    t.integer  "appointment_id"
    t.datetime "scheduled_for"
    t.string   "status"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "user_role"
  end

  create_table "text_coordinators", :force => true do |t|
    t.integer  "appointment_id"
    t.integer  "user_id"
    t.integer  "text_signup_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "text_from_users", :force => true do |t|
    t.text     "body"
    t.datetime "time"
    t.integer  "user_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "incoming_number"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "country"
    t.integer  "appointment_id"
  end

  create_table "text_signups", :force => true do |t|
    t.string   "status"
    t.integer  "user_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "days_available"
    t.string   "day_missing_time"
  end

  create_table "text_to_users", :force => true do |t|
    t.integer  "user_id"
    t.datetime "time"
    t.text     "body"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "received"
    t.integer  "appointment_id"
  end

  create_table "texts", :force => true do |t|
    t.string   "body"
    t.integer  "user_id"
    t.integer  "unit_of_work_id"
    t.string   "unit_of_work_type"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "type"
  end

  create_table "tutoring_session_builders", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "tutoring_sessions", :force => true do |t|
    t.integer  "tutor_id"
    t.integer  "tutee_id"
    t.string   "status"
    t.datetime "time"
    t.integer  "start_page"
    t.integer  "finish_page"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "user_assignments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "assignment_id"
    t.string   "status"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "user_lesson_id"
  end

  create_table "user_lessons", :force => true do |t|
    t.integer  "user_id"
    t.integer  "lesson_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "user_schedules", :force => true do |t|
    t.integer  "user_id"
    t.text     "schedule"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "password_digest"
    t.string   "cell_number"
    t.string   "role"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.boolean  "admin"
    t.string   "name"
    t.boolean  "active"
    t.integer  "per_week"
    t.string   "uid"
    t.string   "oauth_token"
    t.datetime "oauth_expires_at"
    t.string   "image"
    t.string   "time_zone"
    t.string   "twitter_handle"
  end

end
