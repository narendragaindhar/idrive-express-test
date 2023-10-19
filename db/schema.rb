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

ActiveRecord::Schema.define(version: 2023_05_04_045225) do

  create_table "active_storage_attachments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "addresses", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci", force: :cascade do |t|
    t.string "recipient"
    t.string "organization"
    t.string "address"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.string "country"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "addressable_id"
    t.string "addressable_type"
    t.index ["addressable_id", "addressable_type"], name: "index_addresses_on_addressable_id_and_addressable_type"
  end

  create_table "customers", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci", force: :cascade do |t|
    t.string "username"
    t.string "email"
    t.string "name"
    t.string "phone"
    t.string "server"
    t.integer "priority"
    t.bigint "quota"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "product_id", null: false
    t.index ["email"], name: "index_customers_on_email"
    t.index ["name"], name: "index_customers_on_name"
    t.index ["product_id"], name: "index_customers_on_product_id"
    t.index ["server"], name: "index_customers_on_server"
    t.index ["username", "product_id"], name: "index_customers_on_username_and_product_id", unique: true
  end

  create_table "day_counts", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci", force: :cascade do |t|
    t.integer "order_id"
    t.integer "count"
    t.boolean "is_final"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_day_counts_on_order_id"
  end

  create_table "destinations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci", force: :cascade do |t|
    t.string "key"
    t.string "name"
    t.boolean "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "drive_events", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci", force: :cascade do |t|
    t.integer "user_id"
    t.integer "drive_id"
    t.text "event"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["drive_id"], name: "index_drive_events_on_drive_id"
    t.index ["user_id"], name: "index_drive_events_on_user_id"
  end

  create_table "drives", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci", force: :cascade do |t|
    t.string "identification_number"
    t.string "serial"
    t.boolean "active", null: false
    t.boolean "in_use", default: false
    t.bigint "size"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["identification_number", "serial"], name: "index_drives_on_identification_number_and_serial", unique: true
  end

  create_table "order_states", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci", force: :cascade do |t|
    t.integer "user_id"
    t.integer "order_id"
    t.integer "state_id"
    t.text "comments"
    t.boolean "did_notify", null: false
    t.boolean "is_public", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_states_on_order_id"
    t.index ["state_id"], name: "index_order_states_on_state_id"
    t.index ["user_id"], name: "index_order_states_on_user_id"
  end

  create_table "order_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci", force: :cascade do |t|
    t.string "key"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "product_id", null: false
    t.index ["key"], name: "index_order_types_on_key"
    t.index ["product_id"], name: "index_order_types_on_product_id"
  end

  create_table "orders", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci", force: :cascade do |t|
    t.integer "customer_id"
    t.integer "drive_id"
    t.integer "destination_id"
    t.integer "order_type_id"
    t.bigint "size"
    t.string "os"
    t.text "comments"
    t.boolean "needs_review", null: false
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_orders_on_customer_id"
    t.index ["destination_id"], name: "index_orders_on_destination_id"
    t.index ["drive_id"], name: "index_orders_on_drive_id"
    t.index ["order_type_id"], name: "index_orders_on_order_type_id"
    t.index ["size"], name: "index_orders_on_size"
  end

  create_table "orders_users", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci", force: :cascade do |t|
    t.integer "order_id"
    t.integer "user_id"
    t.index ["order_id", "user_id"], name: "index_orders_users_on_order_id_and_user_id", unique: true
  end

  create_table "products", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_products_on_name", unique: true
  end

  create_table "reports", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.text "query", null: false
    t.string "frequency"
    t.string "recipients"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "name", null: false
    t.string "description", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_roles_on_key", unique: true
  end

  create_table "roles_users", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "role_id", null: false
    t.index ["role_id"], name: "index_roles_users_on_role_id"
    t.index ["user_id", "role_id"], name: "index_roles_users_on_user_id_and_role_id", unique: true
    t.index ["user_id"], name: "index_roles_users_on_user_id"
  end

  create_table "states", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci", force: :cascade do |t|
    t.integer "order_type_id"
    t.string "key"
    t.integer "percentage"
    t.string "label"
    t.text "description"
    t.boolean "active", default: true, null: false
    t.boolean "public_by_default", null: false
    t.boolean "notify_by_default", null: false
    t.boolean "is_out_of_our_hands", default: false, null: false
    t.boolean "leaves_us", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_drive_event", default: true, null: false
    t.index ["label"], name: "index_states_on_label"
    t.index ["order_type_id"], name: "index_states_on_order_type_id"
  end

  create_table "users", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci", force: :cascade do |t|
    t.string "email", null: false
    t.string "crypted_password"
    t.string "salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "remember_me_token"
    t.datetime "remember_me_token_expires_at"
    t.string "reset_password_token"
    t.datetime "reset_password_token_expires_at"
    t.datetime "reset_password_email_sent_at"
    t.integer "failed_logins_count", default: 0
    t.datetime "lock_expires_at"
    t.string "unlock_token"
    t.datetime "last_login_at"
    t.datetime "last_logout_at"
    t.datetime "last_activity_at"
    t.string "last_login_from_ip_address"
    t.string "name"
    t.datetime "disabled_at"
    t.string "disabled_reason"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["last_logout_at", "last_activity_at"], name: "index_users_on_last_logout_at_and_last_activity_at"
    t.index ["name"], name: "index_users_on_name"
    t.index ["remember_me_token"], name: "index_users_on_remember_me_token"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token"
    t.index ["unlock_token"], name: "index_users_on_unlock_token"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "customers", "products"
  add_foreign_key "day_counts", "orders"
  add_foreign_key "drive_events", "users"
  add_foreign_key "order_states", "orders"
  add_foreign_key "order_states", "states"
  add_foreign_key "order_states", "users"
  add_foreign_key "order_types", "products"
  add_foreign_key "orders", "customers"
  add_foreign_key "orders", "destinations"
  add_foreign_key "orders", "order_types"
  add_foreign_key "roles_users", "roles"
  add_foreign_key "roles_users", "users"
  add_foreign_key "states", "order_types"
end
