class CreateRespostas < ActiveRecord::Migration[8.1]
  def change
    create_table :respostas do |t|
      t.references :participacao, null: false, foreign_key: true
      t.references :pergunta, null: false, foreign_key: true
      t.references :opcao_resposta, null: false, foreign_key: true

      t.timestamps
    end

    add_index :respostas, [:participacao_id, :pergunta_id], unique: true
  end
end
