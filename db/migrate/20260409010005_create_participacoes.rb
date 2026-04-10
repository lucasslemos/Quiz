class CreateParticipacoes < ActiveRecord::Migration[8.1]
  def change
    create_table :participacoes do |t|
      t.references :campanha, null: false, foreign_key: true
      t.string :nome, null: false
      t.string :email
      t.string :telefone
      t.string :token_participante, null: false
      t.integer :pontuacao, null: false, default: 0
      t.boolean :vencedor, null: false, default: false
      t.datetime :enviado_em

      t.timestamps
    end

    add_index :participacoes, [:campanha_id, :email]
    add_index :participacoes, [:campanha_id, :telefone]
    add_index :participacoes, [:campanha_id, :token_participante], unique: true
  end
end
