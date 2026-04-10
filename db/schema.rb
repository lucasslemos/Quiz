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

ActiveRecord::Schema[8.1].define(version: 2026_04_09_010007) do
  create_table "administradores", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_administradores_on_email", unique: true
  end

  create_table "campanhas", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "fim_em"
    t.datetime "inicio_em"
    t.string "nome", null: false
    t.bigint "quiz_id", null: false
    t.string "slug", null: false
    t.string "status", default: "draft", null: false
    t.datetime "updated_at", null: false
    t.index ["quiz_id"], name: "index_campanhas_on_quiz_id"
    t.index ["slug"], name: "index_campanhas_on_slug", unique: true
    t.index ["status"], name: "index_campanhas_on_status"
  end

  create_table "campos_personalizados", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "obrigatorio", default: false, null: false
    t.text "opcoes", size: :long, collation: "utf8mb4_bin"
    t.integer "posicao", default: 0, null: false
    t.bigint "quiz_id", null: false
    t.string "rotulo", null: false
    t.string "tipo_campo", null: false
    t.datetime "updated_at", null: false
    t.index ["quiz_id", "posicao"], name: "index_campos_personalizados_on_quiz_id_and_posicao"
    t.index ["quiz_id"], name: "index_campos_personalizados_on_quiz_id"
    t.check_constraint "json_valid(`opcoes`)", name: "opcoes"
  end

  create_table "opcoes_resposta", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.boolean "correta", default: false, null: false
    t.datetime "created_at", null: false
    t.bigint "pergunta_id", null: false
    t.integer "posicao", default: 0, null: false
    t.string "texto", null: false
    t.datetime "updated_at", null: false
    t.index ["pergunta_id", "posicao"], name: "index_opcoes_resposta_on_pergunta_id_and_posicao"
    t.index ["pergunta_id"], name: "index_opcoes_resposta_on_pergunta_id"
  end

  create_table "organizadores", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_organizadores_on_email", unique: true
    t.index ["status"], name: "index_organizadores_on_status"
  end

  create_table "participacoes", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.bigint "campanha_id", null: false
    t.datetime "created_at", null: false
    t.string "email"
    t.datetime "enviado_em"
    t.string "nome", null: false
    t.integer "pontuacao", default: 0, null: false
    t.string "telefone"
    t.string "token_participante", null: false
    t.datetime "updated_at", null: false
    t.boolean "vencedor", default: false, null: false
    t.index ["campanha_id", "email"], name: "index_participacoes_on_campanha_id_and_email"
    t.index ["campanha_id", "telefone"], name: "index_participacoes_on_campanha_id_and_telefone"
    t.index ["campanha_id", "token_participante"], name: "index_participacoes_on_campanha_id_and_token_participante", unique: true
    t.index ["campanha_id"], name: "index_participacoes_on_campanha_id"
  end

  create_table "perguntas", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "posicao", default: 0, null: false
    t.bigint "quiz_id", null: false
    t.text "texto", null: false
    t.datetime "updated_at", null: false
    t.index ["quiz_id", "posicao"], name: "index_perguntas_on_quiz_id_and_posicao"
    t.index ["quiz_id"], name: "index_perguntas_on_quiz_id"
  end

  create_table "quizzes", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_state", default: "not_asked", null: false
    t.bigint "organizador_id", null: false
    t.string "phone_state", default: "not_asked", null: false
    t.string "titulo", null: false
    t.datetime "updated_at", null: false
    t.index ["organizador_id"], name: "index_quizzes_on_organizador_id"
  end

  create_table "respostas", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "opcao_resposta_id", null: false
    t.bigint "participacao_id", null: false
    t.bigint "pergunta_id", null: false
    t.datetime "updated_at", null: false
    t.index ["opcao_resposta_id"], name: "index_respostas_on_opcao_resposta_id"
    t.index ["participacao_id", "pergunta_id"], name: "index_respostas_on_participacao_id_and_pergunta_id", unique: true
    t.index ["participacao_id"], name: "index_respostas_on_participacao_id"
    t.index ["pergunta_id"], name: "index_respostas_on_pergunta_id"
  end

  create_table "valores_campo_personalizado", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.bigint "campo_personalizado_id", null: false
    t.datetime "created_at", null: false
    t.bigint "participacao_id", null: false
    t.datetime "updated_at", null: false
    t.text "valor"
    t.index ["campo_personalizado_id"], name: "index_valores_campo_personalizado_on_campo_personalizado_id"
    t.index ["participacao_id", "campo_personalizado_id"], name: "index_valores_campo_part_campo", unique: true
    t.index ["participacao_id"], name: "index_valores_campo_personalizado_on_participacao_id"
  end

  add_foreign_key "campanhas", "quizzes"
  add_foreign_key "campos_personalizados", "quizzes"
  add_foreign_key "opcoes_resposta", "perguntas"
  add_foreign_key "participacoes", "campanhas"
  add_foreign_key "perguntas", "quizzes"
  add_foreign_key "quizzes", "organizadores"
  add_foreign_key "respostas", "opcoes_resposta"
  add_foreign_key "respostas", "participacoes"
  add_foreign_key "respostas", "perguntas"
  add_foreign_key "valores_campo_personalizado", "campos_personalizados"
  add_foreign_key "valores_campo_personalizado", "participacoes"
end
