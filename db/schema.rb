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

ActiveRecord::Schema.define(version: 20140701022527) do

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
  end

  add_index "characters", ["guild_id"], name: "index_characters_on_guild_id", using: :btree
  add_index "characters", ["region", "name", "realm"], name: "index_characters_on_region_and_name_and_realm", unique: true, using: :btree
  add_index "characters", ["verified"], name: "index_characters_on_verified", using: :btree

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
  end

  add_index "guilds", ["name", "realm", "region"], name: "index_guilds_on_name_and_realm_and_region", unique: true, using: :btree
  add_index "guilds", ["name", "realm"], name: "index_guilds_on_name_and_realm", using: :btree
  add_index "guilds", ["name"], name: "index_guilds_on_name", using: :btree

  create_table "races", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "blizzard_id"
    t.string   "side"
  end

  add_index "races", ["blizzard_id", "name"], name: "index_races_on_blizzard_id_and_name", unique: true, using: :btree
  add_index "races", ["blizzard_id"], name: "index_races_on_blizzard_id", using: :btree

  create_table "settings", force: true do |t|
    t.string   "guild"
    t.string   "realm"
    t.string   "region"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_digest"
    t.string   "remember_token"
    t.boolean  "admin",           default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["remember_token"], name: "index_users_on_remember_token", using: :btree

end
