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

ActiveRecord::Schema.define(version: 20160226133218) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"
  enable_extension "uuid-ossp"

  create_table "companies", force: :cascade do |t|
    t.string   "company_name", default: ""
    t.string   "address",      default: ""
    t.string   "city",         default: ""
    t.string   "zip",          default: ""
    t.string   "region",       default: ""
    t.string   "country",      default: ""
    t.integer  "user_id"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "companies", ["user_id"], name: "index_companies_on_user_id", using: :btree

  create_table "configs", force: :cascade do |t|
    t.string   "name"
    t.string   "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "order_items", force: :cascade do |t|
    t.integer  "order_id"
    t.integer  "product_id"
    t.integer  "quantity",                           default: 1
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.decimal  "price",      precision: 8, scale: 2
  end

  create_table "orders", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "state",        default: "active"
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.datetime "purchased_at"
    t.uuid     "uuid",         default: "uuid_generate_v4()"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "address"
    t.string   "city"
    t.string   "zip"
    t.string   "region"
    t.string   "country"
    t.string   "phone"
  end

  create_table "payments", force: :cascade do |t|
    t.integer  "payable_id"
    t.string   "payable_type"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "payments", ["payable_id", "payable_type"], name: "index_payments_on_payable_id_and_payable_type", using: :btree

  create_table "product_templates", force: :cascade do |t|
    t.decimal  "price",         precision: 8, scale: 2
    t.string   "product_type"
    t.string   "size"
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.string   "size_chart_id"
    t.boolean  "is_deleted",                            default: false
  end

  create_table "products", force: :cascade do |t|
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at",                                                          null: false
    t.datetime "updated_at",                                                          null: false
    t.string   "status",                                      default: "unpublished"
    t.integer  "product_template_id"
    t.string   "description"
    t.integer  "likes",                                       default: 0
    t.boolean  "is_deleted",                                  default: false
    t.string   "image_id"
    t.decimal  "price",               precision: 8, scale: 2
    t.boolean  "published",                                   default: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.string   "provider"
    t.string   "uid"
    t.string   "auth_token",                                          null: false
    t.string   "password_reminder_token"
    t.datetime "password_reminder_expiration"
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.boolean  "artist"
    t.string   "password_digest"
    t.string   "status",                       default: "unverified"
    t.boolean  "email_confirmed",              default: false
    t.string   "confirm_token"
    t.string   "handle"
    t.string   "first_name",                   default: ""
    t.string   "last_name",                    default: ""
    t.string   "address",                      default: ""
    t.string   "city",                         default: ""
    t.string   "zip",                          default: ""
    t.string   "region",                       default: ""
    t.string   "country",                      default: ""
    t.string   "phone",                        default: ""
  end

  add_index "users", ["auth_token"], name: "index_users_on_auth_token", unique: true, using: :btree
  add_index "users", ["password_reminder_token"], name: "index_users_on_password_reminder_token", unique: true, using: :btree

end
