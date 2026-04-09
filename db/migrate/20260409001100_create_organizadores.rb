class CreateOrganizadores < ActiveRecord::Migration[8.1]
  def change
    create_table :organizadores do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :status, null: false, default: "pending"

      t.timestamps
    end

    add_index :organizadores, :email, unique: true
    add_index :organizadores, :status
  end
end
