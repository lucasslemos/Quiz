class CreateOpcoesResposta < ActiveRecord::Migration[8.1]
  def change
    create_table :opcoes_resposta do |t|
      t.references :pergunta, null: false, foreign_key: true
      t.string :texto, null: false
      t.boolean :correta, null: false, default: false
      t.integer :posicao, null: false, default: 0

      t.timestamps
    end

    add_index :opcoes_resposta, [:pergunta_id, :posicao]
  end
end
