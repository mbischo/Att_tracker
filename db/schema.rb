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

ActiveRecord::Schema.define(:version => 20090525202003) do

  create_table "boss_kills", :force => true do |t|
    t.string   "boss_name"
    t.datetime "kill_date"
    t.integer  "raid_event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dungeons", :force => true do |t|
    t.string   "name"
    t.string   "mode"
    t.integer  "player_limit"
    t.integer  "chunk_size_in_min"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dungeons_roll_pools", :id => false, :force => true do |t|
    t.integer "roll_pool_id"
    t.integer "dungeon_id"
  end

  create_table "guide_requests", :force => true do |t|
    t.datetime "request_date"
    t.datetime "window_start_date"
    t.integer  "dungeon_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "roll_pool_id"
    t.boolean  "regenerate_me"
  end

  create_table "loot_events", :force => true do |t|
    t.string   "item_name"
    t.datetime "loot_date"
    t.integer  "raid_event_id"
    t.integer  "boss_kill_id"
    t.integer  "toon_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "loot_type"
  end

  create_table "member_participations", :force => true do |t|
    t.integer  "raid_event_id"
    t.integer  "member_id"
    t.integer  "time_chunks_played"
    t.integer  "epics_need"
    t.integer  "epics_greed"
    t.string   "note"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "toon_id"
    t.boolean  "is_manual"
  end

  create_table "member_roll_guides", :force => true do |t|
    t.integer  "member_id"
    t.integer  "dungeon_id"
    t.integer  "guide_request_id"
    t.integer  "roll_percentage"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "members", :force => true do |t|
    t.string   "name"
    t.integer  "main_toon_id"
    t.integer  "epic_need_total"
    t.integer  "epic_greed_total"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "raid_events", :force => true do |t|
    t.string   "name"
    t.integer  "dungeon_id"
    t.datetime "begin_date"
    t.datetime "end_date"
    t.boolean  "is_scheduled"
    t.integer  "time_chunks"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "raid_tracker_source"
    t.string   "reporter"
    t.string   "instance"
    t.string   "begin_number"
    t.boolean  "is_nonrun"
  end

  create_table "roles", :force => true do |t|
    t.string   "title"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  create_table "roll_pools", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "toon_classes", :force => true do |t|
    t.string   "name"
    t.string   "icon"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "toon_roll_guides", :force => true do |t|
    t.integer  "toon_id"
    t.integer  "guide_request_id"
    t.integer  "roll_percentage"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "toons", :force => true do |t|
    t.integer  "member_id"
    t.string   "name"
    t.boolean  "is_main"
    t.string   "spec_note"
    t.integer  "level"
    t.string   "guild"
    t.string   "armory_url"
    t.string   "heroes_url"
    t.integer  "toonClass_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.string   "state",                                   :default => "passive"
    t.datetime "deleted_at"
  end

end
