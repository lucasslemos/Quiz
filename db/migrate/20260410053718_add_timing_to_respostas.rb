class AddTimingToRespostas < ActiveRecord::Migration[8.1]
  def change
    add_column :respostas, :tempo_resposta_ms, :integer
    change_column_null :respostas, :opcao_resposta_id, true
  end
end
