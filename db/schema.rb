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

ActiveRecord::Schema.define(:version => 20130829031916) do

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
  end

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

  create_table "call_to_users", :force => true do |t|
    t.integer  "tutor_id"
    t.integer  "tutee_id"
    t.datetime "begin_time"
    t.datetime "end_time"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "appointment_id"
  end

  create_table "matches", :force => true do |t|
    t.integer  "tutor_id"
    t.integer  "tutee_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "openings", :force => true do |t|
    t.integer  "user_id"
    t.integer  "time_open"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "day_open"
  end

  create_table "reminder_texts", :force => true do |t|
    t.integer  "appointment_id"
    t.datetime "time"
    t.integer  "user_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "type"
  end

  create_table "schedules", :force => true do |t|
    t.integer  "user_id"
    t.text     "schedule"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "text_from_users", :force => true do |t|
    t.text     "body"
    t.datetime "time"
    t.integer  "user_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "incoming_number"
  end

  create_table "text_to_users", :force => true do |t|
    t.integer  "user_id"
    t.datetime "time"
    t.text     "body"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
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
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.boolean  "admin"
    t.string   "name"
    t.boolean  "active"
    t.integer  "per_week"
  end

end
