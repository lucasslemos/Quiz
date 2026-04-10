class AddTempoPerPerguntaToQuizzes < ActiveRecord::Migration[8.1]
  def change
    add_column :quizzes, :tempo_por_pergunta, :integer, null: false, default: 30
  end
end
