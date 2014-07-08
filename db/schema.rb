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

ActiveRecord::Schema.define(version: 20140708034157) do

  create_table "character_classes", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "blizzard_id"
  end

  add_index "character_classes", ["blizzard_id"], name: "index_character_classes_on_blizzard_id", using: :btree

  create_table "characters", force: true do |t|
    t.integer  "achievement_points"
    t.integer  "gender"
    t.integer  "level"
    t.string   "portrait"
    t.string   "name"
    t.integer  "rank"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "race_id"
    t.integer  "character_class_id"
    t.string   "realm"
    t.string   "region"
    t.integer  "guild_id"
    t.boolean  "verified",           default: false
    t.datetime "synced_at"
    t.string   "slug"
    t.integer  "user_id"
  end

  add_index "characters", ["guild_id"], name: "index_characters_on_guild_id", using: :btree
  add_index "characters", ["region", "name", "realm"], name: "index_characters_on_region_and_name_and_realm", unique: true, using: :btree
  add_index "characters", ["slug"], name: "index_characters_on_slug", unique: true, using: :btree
  add_index "characters", ["user_id"], name: "index_characters_on_user_id", using: :btree
  add_index "characters", ["verified"], name: "index_characters_on_verified", using: :btree

  create_table "events", force: true do |t|
    t.string   "actor_type"
    t.integer  "actor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "events", ["actor_id"], name: "index_events_on_actor_id", using: :btree

  create_table "guilds", force: true do |t|
    t.integer  "achievement_points"
    t.boolean  "active"
    t.string   "battlegroup"
    t.boolean  "primary"
    t.integer  "level"
    t.string   "name"
    t.string   "realm"
    t.string   "region"
    t.integer  "side"
    t.boolean  "verified"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
  end

  add_index "guilds", ["name", "realm", "region"], name: "index_guilds_on_name_and_realm_and_region", unique: true, using: :btree
  add_index "guilds", ["name", "realm"], name: "index_guilds_on_name_and_realm", using: :btree
  add_index "guilds", ["name"], name: "index_guilds_on_name", using: :btree
  add_index "guilds", ["slug"], name: "index_guilds_on_slug", unique: true, using: :btree

  create_table "participations", force: true do |t|
    t.integer  "character_id"
    t.integer  "raid_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "in_raid",      default: false
    t.boolean  "online",       default: false
    t.datetime "timestamp"
  end

  add_index "participations", ["character_id", "raid_id", "timestamp"], name: "index_participations_on_character_id_and_raid_id_and_timestamp", unique: true, using: :btree

  create_table "races", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "blizzard_id"
    t.string   "side"
  end

  add_index "races", ["blizzard_id", "name"], name: "index_races_on_blizzard_id_and_name", unique: true, using: :btree
  add_index "races", ["blizzard_id"], name: "index_races_on_blizzard_id", using: :btree

  create_table "raids", force: true do |t|
    t.datetime "started_at"
    t.datetime "ended_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "zones_id"
  end

  add_index "raids", ["zones_id"], name: "index_raids_on_zones_id", using: :btree

  create_table "settings", force: true do |t|
    t.string   "guild"
    t.string   "realm"
    t.string   "region"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "standings", force: true do |t|
    t.boolean  "active",                                default: false
    t.decimal  "points",       precision: 10, scale: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "character_id"
  end

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_digest"
    t.string   "remember_token"
    t.boolean  "admin",           default: false
    t.string   "secret_key"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["remember_token"], name: "index_users_on_remember_token", using: :btree
  add_index "users", ["secret_key"], name: "index_users_on_secret_key", unique: true, using: :btree

  create_table "versions", force: true do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  create_table "zones", force: true do |t|
    t.integer  "blizzard_id"
    t.integer  "level"
    t.string   "name"
    t.string   "zone_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
