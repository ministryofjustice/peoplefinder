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

ActiveRecord::Schema.define(version: 20140905135531) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "reviews", force: true do |t|
    t.integer "subject_id"
    t.text    "author_name"
    t.text    "author_email"
    t.text    "relationship"
    t.text    "status",       default: "no_response", null: false
    t.string  "rating"
    t.text    "achievements"
    t.text    "improvements"
    t.text    "reason_declined"
    t.text    "invitation_message",                         null: false
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
    t.text     "email",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "manager_id"
    t.boolean  "participant", default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["manager_id"], name: "index_users_on_manager_id", using: :btree

end
