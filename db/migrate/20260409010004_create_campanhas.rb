class CreateCampanhas < ActiveRecord::Migration[8.1]
  def change
    create_table :campanhas do |t|
      t.references :quiz, null: false, foreign_key: true
      t.string :nome, null: false
      t.string :slug, null: false
      t.string :status, null: false, default: "draft"
      t.datetime :inicio_em
      t.datetime :fim_em

      t.timestamps
    end

    add_index :campanhas, :slug, unique: true
    add_index :campanhas, :status
  end
end
