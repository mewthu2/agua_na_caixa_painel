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

ActiveRecord::Schema[7.1].define(version: 2024_09_04_165216) do
  create_table "attempts", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "kinds"
    t.bigint "status"
    t.text "requisition"
    t.text "params"
    t.string "error"
    t.string "status_code"
    t.string "message"
    t.string "exception"
    t.string "classification"
    t.string "cause"
    t.string "url"
    t.string "user"
    t.integer "tiny_order_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "contacts", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "origin"
    t.string "codigo"
    t.string "nome"
    t.string "fantasia"
    t.string "tipo_pessoa"
    t.string "cpf_cnpj"
    t.string "endereco"
    t.string "numero"
    t.string "complemento"
    t.string "bairro"
    t.string "cep"
    t.string "cidade"
    t.string "uf"
    t.string "email"
    t.string "fone"
    t.integer "id_lista_preco"
    t.integer "id_vendedor"
    t.string "nome_vendedor"
    t.string "situacao"
    t.datetime "data_criacao"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "order_payment_types", charset: "utf8mb3", force: :cascade do |t|
    t.string "payment_method", null: false
    t.string "payment_channel", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "order_payments", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "order_payment_types_id"
    t.bigint "order_id"
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.integer "days", null: false
    t.date "date", null: false
    t.string "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_payments_on_order_id"
    t.index ["order_payment_types_id"], name: "index_order_payments_on_order_payment_types_id"
  end

  create_table "order_products", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "order_id"
    t.bigint "product_id"
    t.integer "quantidade"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_products_on_order_id"
    t.index ["product_id"], name: "index_order_products_on_product_id"
  end

  create_table "orders", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "contact_id"
    t.boolean "use_contact_order", default: true
    t.string "endereco"
    t.string "numero"
    t.string "complemento"
    t.string "bairro"
    t.string "cep"
    t.string "uf"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "destiny", default: 0, null: false
    t.index ["contact_id"], name: "index_orders_on_contact_id"
  end

  create_table "products", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "origin"
    t.bigint "contact_id"
    t.datetime "data_criacao"
    t.string "nome"
    t.string "codigo"
    t.decimal "preco", precision: 10, scale: 2, default: "0.0"
    t.decimal "preco_promocional", precision: 10, scale: 2, default: "0.0"
    t.string "unidade"
    t.string "gtin"
    t.string "tipoVariacao"
    t.string "localizacao"
    t.decimal "preco_custo", precision: 10, scale: 2, default: "0.0"
    t.decimal "preco_custo_medio", precision: 10, scale: 2, default: "0.0"
    t.string "situacao"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_id"], name: "index_products_on_contact_id"
  end

  create_table "profiles", charset: "utf8mb3", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "profile_id"
    t.string "name"
    t.string "phone"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.string "unlock_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["profile_id"], name: "index_users_on_profile_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "order_payments", "order_payment_types", column: "order_payment_types_id"
  add_foreign_key "order_payments", "orders"
  add_foreign_key "order_products", "orders"
  add_foreign_key "order_products", "products"
  add_foreign_key "orders", "contacts"
  add_foreign_key "products", "contacts"
  add_foreign_key "users", "profiles"
end
