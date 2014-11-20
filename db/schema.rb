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

ActiveRecord::Schema.define(version: 20141120150808) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "identities", force: true do |t|
    t.text     "username",                  null: false
    t.text     "password_digest",           null: false
    t.integer  "user_id",                   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_reset_token"
    t.datetime "password_reset_expires_at"
  end

  add_index "identities", ["username"], name: "index_identities_on_username", unique: true, using: :btree

  create_table "review_periods", force: true do |t|
    t.datetime "closes_at", null: false
  end

  create_table "reviews", force: true do |t|
    t.integer "subject_id"
    t.text    "author_name"
    t.text    "author_email"
    t.text    "relationship"
    t.text    "status",               default: "no_response", null: false
    t.text    "reason_declined"
    t.text    "invitation_message",                           null: false
    t.integer "rating_1"
    t.integer "rating_2"
    t.integer "rating_3"
    t.integer "rating_4"
    t.integer "rating_5"
    t.integer "rating_6"
    t.integer "rating_7"
    t.integer "rating_8"
    t.integer "rating_9"
    t.integer "rating_10"
    t.integer "rating_11"
    t.text    "leadership_comments"
    t.text    "how_we_work_comments"
  end

  add_index "reviews", ["author_email"], name: "index_reviews_on_author_email", using: :btree

  create_table "tokens", force: true do |t|
    t.text     "value"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "review_id"
  end

  add_index "tokens", ["user_id"], name: "index_tokens_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.text     "name"
    t.text     "email",                         null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "manager_id"
    t.boolean  "participant",   default: false
    t.boolean  "administrator", default: false, null: false
    t.text     "job_title"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["manager_id"], name: "index_users_on_manager_id", using: :btree

end
