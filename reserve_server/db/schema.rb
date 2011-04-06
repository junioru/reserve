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

ActiveRecord::Schema.define(:version => 20110324115941) do

  create_table "ratings", :force => true do |t|
    t.integer  "user_id"
    t.integer  "resource_id"
    t.integer  "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reservation_floorplans", :force => true do |t|
    t.string   "caption"
    t.integer  "reservation_system_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "floorplan_file_name"
    t.string   "floorplan_content_type"
    t.integer  "floorplan_file_size"
    t.datetime "floorplan_updated_at"
  end

  create_table "reservation_systems", :force => true do |t|
    t.integer  "user_id"
    t.string   "category"
    t.string   "name"
    t.string   "location"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "delta",       :default => true, :null => false
    t.string   "address"
  end

  add_index "reservation_systems", ["category"], :name => "index_reservation_systems_on_category"
  add_index "reservation_systems", ["location"], :name => "index_reservation_systems_on_location"
  add_index "reservation_systems", ["user_id"], :name => "index_reservation_systems_on_user_id"

  create_table "reservations", :force => true do |t|
    t.integer  "user_id"
    t.integer  "resource_id"
    t.datetime "startDate"
    t.datetime "endDate"
    t.string   "recurring"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "delta",       :default => true,        :null => false
    t.string   "status",      :default => "confirmed"
  end

  add_index "reservations", ["endDate"], :name => "index_reservations_on_endDate"
  add_index "reservations", ["resource_id"], :name => "index_reservations_on_resource_id"
  add_index "reservations", ["startDate"], :name => "index_reservations_on_startDate"
  add_index "reservations", ["user_id"], :name => "index_reservations_on_user_id"

  create_table "resources", :force => true do |t|
    t.integer  "reservation_system_id"
    t.string   "name"
    t.integer  "capacity"
    t.text     "description"
    t.string   "startTime"
    t.string   "endTime"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.integer  "min_duration"
    t.boolean  "delta",                    :default => true, :null => false
    t.boolean  "cancellation",             :default => true, :null => false
    t.string   "html"
    t.integer  "reservation_floorplan_id"
    t.boolean  "allowcancel",              :default => true
  end

  add_index "resources", ["capacity"], :name => "index_resources_on_capacity"
  add_index "resources", ["endTime"], :name => "index_resources_on_endTime"
  add_index "resources", ["reservation_system_id"], :name => "index_resources_on_reservation_system_id"
  add_index "resources", ["startTime"], :name => "index_resources_on_startTime"

  create_table "system_reservations", :force => true do |t|
    t.integer  "reservation_system_id"
    t.datetime "startDate"
    t.datetime "endDate"
    t.string   "recurring"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "encrypted_password"
    t.string   "salt"
    t.string   "mobile_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "user_type",          :default => "personal"
    t.string   "business_name"
    t.string   "business_category"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["mobile_number"], :name => "index_users_on_mobile_number", :unique => true

end
