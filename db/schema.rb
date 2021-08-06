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

ActiveRecord::Schema.define(version: 2021_08_02_151202) do

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "purchase_requests", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "item_id", null: false
    t.integer "stack", null: false
    t.integer "coin_count"
    t.integer "transaction_type", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_purchase_requests_on_user_id"
  end

  create_table "purchased_items", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "selling_item_id", null: false
    t.integer "slot_index", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["selling_item_id"], name: "index_purchased_items_on_selling_item_id"
    t.index ["user_id"], name: "index_purchased_items_on_user_id"
  end

  create_table "selling_item_barter_items", force: :cascade do |t|
    t.integer "selling_item_id", null: false
    t.integer "item_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["item_id"], name: "index_selling_item_barter_items_on_item_id"
    t.index ["selling_item_id"], name: "index_selling_item_barter_items_on_selling_item_id"
  end

  create_table "selling_items", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "item_id", null: false
    t.integer "stack", null: false
    t.integer "prefix_id", null: false
    t.integer "slot_index", null: false
    t.integer "transaction_type", null: false
    t.integer "coin_count"
    t.integer "status", default: 0, null: false
    t.datetime "canceled_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_selling_items_on_user_id"
  end

end
