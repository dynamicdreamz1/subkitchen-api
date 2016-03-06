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

ActiveRecord::Schema.define(version: 20160306151903) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
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

  create_table "likes", force: :cascade do |t|
    t.integer  "likeable_id"
    t.string   "likeable_type"
    t.integer  "user_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "likes", ["likeable_id", "likeable_type"], name: "index_likes_on_likeable_id_and_likeable_type", using: :btree

  create_table "order_items", force: :cascade do |t|
    t.integer  "order_id"
    t.integer  "product_id"
    t.integer  "quantity",                                    default: 1
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.decimal  "price",               precision: 8, scale: 2
    t.string   "size"
    t.string   "product_name"
    t.string   "product_description"
    t.string   "product_author"
  end

  create_table "orders", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at",                                                           null: false
    t.datetime "updated_at",                                                           null: false
    t.datetime "purchased_at"
    t.uuid     "uuid",                                  default: "uuid_generate_v4()"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "address"
    t.string   "city"
    t.string   "zip"
    t.string   "region"
    t.string   "country"
    t.string   "phone"
    t.decimal  "subtotal_cost", precision: 8, scale: 2, default: 0.0
    t.decimal  "shipping_cost", precision: 8, scale: 2
    t.decimal  "tax",           precision: 4, scale: 2
    t.decimal  "tax_cost",      precision: 8, scale: 2, default: 0.0
    t.decimal  "total_cost",    precision: 8, scale: 2, default: 0.0
    t.boolean  "purchased",                             default: false
    t.boolean  "active",                                default: true
    t.string   "order_status",                          default: "creating"
  end

  create_table "payments", force: :cascade do |t|
    t.integer  "payable_id"
    t.string   "payable_type"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.string   "payment_status", default: "pending"
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
    t.decimal  "profit",        precision: 8, scale: 2
  end

  create_table "products", force: :cascade do |t|
    t.string   "name"
    t.integer  "author_id"
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
    t.datetime "published_at"
    t.string   "design_id"
    t.integer  "order_items_count",                           default: 0
  end

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

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
    t.boolean  "has_company",                  default: false
    t.string   "profile_image_id"
    t.string   "shop_banner_id"
  end

  add_index "users", ["auth_token"], name: "index_users_on_auth_token", unique: true, using: :btree
  add_index "users", ["password_reminder_token"], name: "index_users_on_password_reminder_token", unique: true, using: :btree

end
