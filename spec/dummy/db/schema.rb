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

ActiveRecord::Schema.define(version: 20150212132353) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "communities", force: true do |t|
    t.string   "name",       limit: nil
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", force: true do |t|
    t.text     "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug",               limit: nil
    t.text     "description"
    t.text     "ancestry"
    t.integer  "ancestry_depth",                 default: 0, null: false
    t.text     "team_email_address"
  end

  add_index "groups", ["ancestry"], name: "index_groups_on_ancestry", using: :btree
  add_index "groups", ["slug"], name: "index_groups_on_slug", using: :btree

  create_table "information_requests", force: true do |t|
    t.integer "recipient_id"
    t.string  "sender_email", limit: nil
    t.text    "message"
    t.string  "type",         limit: nil
  end

  add_index "information_requests", ["sender_email"], name: "index_information_requests_on_sender_email", using: :btree
  add_index "information_requests", ["type"], name: "index_information_requests_on_type", using: :btree

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
    t.boolean  "works_monday",                       default: true
    t.boolean  "works_tuesday",                      default: true
    t.boolean  "works_wednesday",                    default: true
    t.boolean  "works_thursday",                     default: true
    t.boolean  "works_friday",                       default: true
    t.string   "image",                  limit: nil
    t.string   "slug",                   limit: nil
    t.boolean  "works_saturday",                     default: false
    t.boolean  "works_sunday",                       default: false
    t.boolean  "no_phone",                           default: false
    t.text     "tags"
    t.integer  "community_id"
    t.integer  "login_count",                        default: 0,     null: false
    t.datetime "last_login_at"
    t.boolean  "super_admin",                        default: false
  end

  add_index "people", ["slug"], name: "index_people_on_slug", unique: true, using: :btree

  create_table "peoplefinder_taggings", force: true do |t|
    t.integer  "tag_id"
    t.integer  "article_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "peoplefinder_taggings", ["article_id"], name: "index_peoplefinder_taggings_on_article_id", using: :btree
  add_index "peoplefinder_taggings", ["tag_id"], name: "index_peoplefinder_taggings_on_tag_id", using: :btree

  create_table "reported_profiles", force: true do |t|
    t.integer "notifier_id"
    t.integer "subject_id"
    t.string  "recipient_email",      limit: nil
    t.text    "reason_for_reporting"
    t.text    "additional_details"
  end

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
    t.string   "ip_address"
    t.string   "user_agent"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

end
