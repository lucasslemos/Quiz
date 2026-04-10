class CreateCamposPersonalizados < ActiveRecord::Migration[8.1]
  def change
    create_table :campos_personalizados do |t|
      t.references :quiz, null: false, foreign_key: true
      t.string :rotulo, null: false
      t.string :tipo_campo, null: false
      t.boolean :obrigatorio, null: false, default: false
      t.json :opcoes
      t.integer :posicao, null: false, default: 0

      t.timestamps
    end

    add_index :campos_personalizados, [:quiz_id, :posicao]
  end
end
