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

ActiveRecord::Schema.define(version: 20161218155717) do

  create_table "game_words", force: :cascade do |t|
    t.integer  "game_id"
    t.integer  "player_id"
    t.string   "previous_letter"
    t.string   "word"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["game_id"], name: "index_game_words_on_game_id"
    t.index ["player_id"], name: "index_game_words_on_player_id"
  end

  create_table "games", force: :cascade do |t|
    t.integer  "player1_id"
    t.integer  "player1_score"
    t.integer  "player2_id"
    t.integer  "player2_score"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["player1_id"], name: "index_games_on_player1_id"
    t.index ["player2_id"], name: "index_games_on_player2_id"
  end

  create_table "players", force: :cascade do |t|
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "username"
    t.boolean  "guest",                  default: false
    t.boolean  "ai",                     default: false
    t.index ["reset_password_token"], name: "index_players_on_reset_password_token", unique: true
    t.index ["username"], name: "index_players_on_username", unique: true
  end

end
