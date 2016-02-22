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

ActiveRecord::Schema.define(version: 20160222135847) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "product_templates", force: :cascade do |t|
    t.decimal  "price",         precision: 8, scale: 2
    t.string   "product_type"
    t.string   "size"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.string   "size_chart_id"
    t.integer  "shipping_id"
  end

  create_table "products", force: :cascade do |t|
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "product_template_id"
    t.string   "description"
    t.integer  "likes",               default: 0
  end

  create_table "shippings", force: :cascade do |t|
    t.string   "info"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.string   "provider"
    t.string   "uid"
    t.string   "auth_token",                   null: false
    t.string   "password_reminder_token"
    t.datetime "password_reminder_expiration"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.boolean  "artist"
    t.string   "password_digest"
  end

  add_index "users", ["auth_token"], name: "index_users_on_auth_token", unique: true, using: :btree
  add_index "users", ["password_reminder_token"], name: "index_users_on_password_reminder_token", unique: true, using: :btree

end
