class CreateQuizzes < ActiveRecord::Migration[8.1]
  def change
    create_table :quizzes do |t|
      t.references :organizador, null: false, foreign_key: true
      t.string :titulo, null: false
      t.string :email_state, null: false, default: "not_asked"
      t.string :phone_state, null: false, default: "not_asked"

      t.timestamps
    end
  end
end
