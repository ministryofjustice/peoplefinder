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

ActiveRecord::Schema.define(version: 20140827103704) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_stat_statements"

  create_table "groups", force: true do |t|
    t.text     "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
    t.text     "description"
    t.text     "responsibilities"
    t.text     "ancestry"
    t.integer  "ancestry_depth",   default: 0, null: false
  end

  add_index "groups", ["ancestry"], name: "index_groups_on_ancestry", using: :btree
  add_index "groups", ["slug"], name: "index_groups_on_slug", using: :btree

  create_table "memberships", force: true do |t|
    t.integer  "group_id"
    t.integer  "person_id"
    t.text     "role"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "leader",     default: false
  end

  add_index "memberships", ["group_id"], name: "index_memberships_on_group_id", using: :btree
  add_index "memberships", ["person_id"], name: "index_memberships_on_person_id", using: :btree

  create_table "people", force: true do |t|
    t.text     "given_name"
    t.text     "surname"
    t.text     "email"
    t.text     "primary_phone_number"
    t.text     "secondary_phone_number"
    t.text     "location"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "works_monday",           default: true
    t.boolean  "works_tuesday",          default: true
    t.boolean  "works_wednesday",        default: true
    t.boolean  "works_thursday",         default: true
    t.boolean  "works_friday",           default: true
    t.string   "image"
    t.string   "slug"
    t.boolean  "works_saturday",         default: false
    t.boolean  "works_sunday",           default: false
  end

  add_index "people", ["slug"], name: "index_people_on_slug", unique: true, using: :btree

  create_table "tokens", force: true do |t|
    t.text     "value"
    t.text     "user_email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "versions", force: true do |t|
    t.text     "item_type",      null: false
    t.integer  "item_id",        null: false
    t.text     "event",          null: false
    t.text     "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.text     "object_changes"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

end
