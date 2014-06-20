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

ActiveRecord::Schema.define(version: 20140620094222) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "groups", force: true do |t|
    t.integer  "parent_id"
    t.text     "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
    t.text     "description"
  end

  add_index "groups", ["parent_id"], name: "index_groups_on_parent_id", using: :btree
  add_index "groups", ["slug"], name: "index_groups_on_slug", unique: true, using: :btree

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
    t.string   "given_name"
    t.string   "surname"
    t.string   "email"
    t.string   "phone"
    t.string   "mobile"
    t.string   "location"
    t.string   "keywords"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "works_monday",    default: true
    t.boolean  "works_tuesday",   default: true
    t.boolean  "works_wednesday", default: true
    t.boolean  "works_thursday",  default: true
    t.boolean  "works_friday",    default: true
  end

end
