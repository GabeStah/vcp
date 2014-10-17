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

ActiveRecord::Schema.define(version: 20141017064819) do

  create_table "assignments", force: true do |t|
    t.integer "role_id", null: false
    t.integer "user_id", null: false
  end

  add_index "assignments", ["role_id", "user_id"], name: "index_assignments_on_role_id_and_user_id", unique: true, using: :btree

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
    t.integer  "raid_id"
    t.decimal  "change",     precision: 10, scale: 6
    t.string   "type"
    t.integer  "parent_id"
  end

  add_index "events", ["actor_id"], name: "index_events_on_actor_id", using: :btree
  add_index "events", ["raid_id"], name: "index_events_on_raid_id", using: :btree

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

  create_table "identities", force: true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "identities", ["user_id"], name: "index_identities_on_user_id", using: :btree

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
    t.integer  "zone_id"
    t.boolean  "processed",                                default: false
    t.decimal  "attendance_loss", precision: 10, scale: 6
  end

  add_index "raids", ["zone_id"], name: "index_raids_on_zone_id", using: :btree

  create_table "roles", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "settings", force: true do |t|
    t.string   "raid_start_time"
    t.string   "raid_end_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tardiness_cutoff_time", default: 60
  end

  create_table "sidekiq_jobs", force: true do |t|
    t.string   "jid"
    t.string   "queue"
    t.string   "class_name"
    t.text     "args"
    t.boolean  "retry"
    t.datetime "enqueued_at"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.string   "status"
    t.string   "name"
    t.text     "result"
  end

  add_index "sidekiq_jobs", ["class_name"], name: "index_sidekiq_jobs_on_class_name", using: :btree
  add_index "sidekiq_jobs", ["enqueued_at"], name: "index_sidekiq_jobs_on_enqueued_at", using: :btree
  add_index "sidekiq_jobs", ["finished_at"], name: "index_sidekiq_jobs_on_finished_at", using: :btree
  add_index "sidekiq_jobs", ["jid"], name: "index_sidekiq_jobs_on_jid", using: :btree
  add_index "sidekiq_jobs", ["queue"], name: "index_sidekiq_jobs_on_queue", using: :btree
  add_index "sidekiq_jobs", ["retry"], name: "index_sidekiq_jobs_on_retry", using: :btree
  add_index "sidekiq_jobs", ["started_at"], name: "index_sidekiq_jobs_on_started_at", using: :btree
  add_index "sidekiq_jobs", ["status"], name: "index_sidekiq_jobs_on_status", using: :btree

  create_table "standings", force: true do |t|
    t.boolean  "active",                                default: false
    t.decimal  "points",       precision: 10, scale: 6, default: 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "character_id"
  end

  create_table "statistics", force: true do |t|
    t.string   "record_type"
    t.integer  "record_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "gains_delinquency",            precision: 10, scale: 6, default: 0.0
    t.decimal  "gains_infraction",             precision: 10, scale: 6, default: 0.0
    t.decimal  "gains_sitting",                precision: 10, scale: 6, default: 0.0
    t.decimal  "gains_total",                  precision: 10, scale: 6, default: 0.0
    t.decimal  "losses_attendance",            precision: 10, scale: 6, default: 0.0
    t.decimal  "losses_absence",               precision: 10, scale: 6, default: 0.0
    t.decimal  "losses_delinquency",           precision: 10, scale: 6, default: 0.0
    t.decimal  "losses_infraction",            precision: 10, scale: 6, default: 0.0
    t.decimal  "losses_total",                 precision: 10, scale: 6, default: 0.0
    t.integer  "raids_absent_three_month"
    t.integer  "raids_absent_year"
    t.integer  "raids_absent_total"
    t.decimal  "raids_absent_percent",         precision: 10, scale: 6, default: 0.0
    t.integer  "raids_attended_three_month"
    t.integer  "raids_attended_year"
    t.integer  "raids_attended_total"
    t.decimal  "raids_attended_percent",       precision: 10, scale: 6, default: 0.0
    t.integer  "raids_delinquent_three_month"
    t.integer  "raids_delinquent_year"
    t.integer  "raids_delinquent_total"
    t.decimal  "raids_delinquent_percent",     precision: 10, scale: 6, default: 0.0
    t.integer  "raids_sat_three_month"
    t.integer  "raids_sat_year"
    t.integer  "raids_sat_total"
    t.decimal  "raids_sat_percent",            precision: 10, scale: 6, default: 0.0
    t.integer  "time_raiding_three_month"
    t.integer  "time_raiding_year"
    t.integer  "time_absent_three_month"
    t.integer  "time_absent_year"
    t.integer  "time_delinquent_three_month"
    t.integer  "time_delinquent_year"
  end

  add_index "statistics", ["record_type", "record_id"], name: "index_statistics_on_record_type_and_record_id", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "secret_key"
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
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
