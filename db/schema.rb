# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_08_22_055333) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "app_users", force: :cascade do |t|
    t.string "username"
    t.string "password"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "comicbooks", force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.string "img_url"
    t.integer "publisher_id"
    t.integer "number"
    t.string "artist"
    t.string "writer"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "groups", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "publishers", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "app_user_id", null: false
    t.string "stripe_subscription_id"
    t.string "status"
    t.string "plan"
    t.string "│"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "stripe_customer_id"
    t.datetime "current_period_start"
    t.datetime "current_period_end"
    t.index ["app_user_id"], name: "index_subscriptions_on_app_user_id"
  end

  create_table "todos", force: :cascade do |t|
    t.string "todo_name"
    t.boolean "completed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.integer "app_user_id"
  end

  create_table "user_logins", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "username"
    t.string "token"
    t.string "refresh_token"
    t.datetime "token_exp_time"
    t.datetime "ref_token_exp_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_logins_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "password"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "subscriptions", "app_users"
  add_foreign_key "user_logins", "app_users", column: "user_id"
end
