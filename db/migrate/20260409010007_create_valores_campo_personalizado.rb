class CreateValoresCampoPersonalizado < ActiveRecord::Migration[8.1]
  def change
    create_table :valores_campo_personalizado do |t|
      t.references :participacao, null: false, foreign_key: true
      t.references :campo_personalizado, null: false, foreign_key: true
      t.text :valor

      t.timestamps
    end

    add_index :valores_campo_personalizado,
              [:participacao_id, :campo_personalizado_id],
              unique: true,
              name: "index_valores_campo_part_campo"
  end
end
