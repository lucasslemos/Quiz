class CreateAdministradores < ActiveRecord::Migration[8.1]
  def change
    create_table :administradores do |t|
      t.string :email, null: false
      t.string :password_digest, null: false

      t.timestamps
    end

    add_index :administradores, :email, unique: true
  end
end
