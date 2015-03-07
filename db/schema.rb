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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150306093708) do

  create_table "crews", force: :cascade do |t|
    t.string   "boat_name"
    t.string   "captain_name"
    t.string   "captain_email"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "last_point_id"
    t.boolean  "finished",       default: false
    t.datetime "game_time"
    t.float    "log",            default: 0.0
    t.float    "trip",           default: 0.0
    t.integer  "start_point_id"
    t.float    "distance",       default: 0.0
  end

  create_table "crews_points", force: :cascade do |t|
    t.integer  "crews_id"
    t.integer  "point_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "crews_sections", force: :cascade do |t|
    t.integer "crew_id"
    t.integer "section_id"
  end

  add_index "crews_sections", ["crew_id", "section_id"], name: "index_crews_sections_on_crew_id_and_section_id", unique: true
  add_index "crews_sections", ["crew_id"], name: "index_crews_sections_on_crew_id"
  add_index "crews_sections", ["section_id"], name: "index_crews_sections_on_section_id"

  create_table "log_entries", force: :cascade do |t|
    t.integer  "point_id"
    t.integer  "to_point_id"
    t.datetime "from_time"
    t.datetime "to_time"
    t.string   "description"
    t.integer  "position"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "crew_id"
    t.float    "distance",    default: 0.0
    t.float    "twd"
    t.float    "tws"
  end

  add_index "log_entries", ["crew_id", "point_id", "to_point_id"], name: "index_log_entries_on_crew_id_and_point_id_and_to_point_id"
  add_index "log_entries", ["crew_id", "to_point_id"], name: "index_log_entries_on_crew_id_and_to_point_id"
  add_index "log_entries", ["crew_id"], name: "index_log_entries_on_crew_id"
  add_index "log_entries", ["point_id", "to_point_id"], name: "index_log_entries_on_point_id_and_to_point_id"
  add_index "log_entries", ["point_id"], name: "index_log_entries_on_point_id"
  add_index "log_entries", ["to_point_id"], name: "index_log_entries_on_to_point_id"

  create_table "organizers", force: :cascade do |t|
    t.string   "name"
    t.string   "fk_org_code"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "organizers", ["fk_org_code"], name: "index_organizers_on_fk_org_code"

  create_table "organizers_points", force: :cascade do |t|
    t.integer  "organizer_id"
    t.integer  "point_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "organizers_points", ["organizer_id", "point_id"], name: "index_organizers_points_on_organizer_id_and_point_id", unique: true

  create_table "points", force: :cascade do |t|
    t.integer  "number"
    t.string   "name"
    t.string   "definition"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float    "latitude"
    t.float    "longitude"
  end

  create_table "sections", force: :cascade do |t|
    t.integer  "point_id"
    t.integer  "to_point_id"
    t.float    "distance"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "sections", ["point_id", "to_point_id"], name: "index_sections_on_point_id_and_to_point_id"
  add_index "sections", ["point_id"], name: "index_sections_on_point_id"
  add_index "sections", ["to_point_id"], name: "index_sections_on_to_point_id"

end
