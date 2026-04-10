class CreatePerguntas < ActiveRecord::Migration[8.1]
  def change
    create_table :perguntas do |t|
      t.references :quiz, null: false, foreign_key: true
      t.text :texto, null: false
      t.integer :posicao, null: false, default: 0

      t.timestamps
    end

    add_index :perguntas, [:quiz_id, :posicao]
  end
end
