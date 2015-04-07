class InitialSchema < ActiveRecord::Migration
  def change
     create_table "groups", force: true do |t|
      t.text     "name"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "slug"
      t.text     "description"
      t.text     "responsibilities"
      t.text     "ancestry"
      t.integer  "ancestry_depth",     default: 0, null: false
      t.text     "team_email_address"
    end

    add_index "groups", ["ancestry"], name: "index_groups_on_ancestry", using: :btree
    add_index "groups", ["slug"], name: "index_groups_on_slug", using: :btree

    create_table "information_requests", force: true do |t|
      t.integer "recipient_id"
      t.string  "sender_email"
      t.text    "message"
      t.string  "type"
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
      t.boolean  "works_monday",           default: true
      t.boolean  "works_tuesday",          default: true
      t.boolean  "works_wednesday",        default: true
      t.boolean  "works_thursday",         default: true
      t.boolean  "works_friday",           default: true
      t.string   "image"
      t.string   "slug"
      t.boolean  "works_saturday",         default: false
      t.boolean  "works_sunday",           default: false
      t.boolean  "no_phone",               default: false
    end

    add_index "people", ["slug"], name: "index_people_on_slug", unique: true, using: :btree

    create_table "reported_profiles", force: true do |t|
      t.integer "notifier_id"
      t.integer "subject_id"
      t.string  "recipient_email"
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
    end

    add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree
  end
end
