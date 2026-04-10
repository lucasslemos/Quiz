class AddTempoTotalMsToParticipacoes < ActiveRecord::Migration[8.1]
  def change
    add_column :participacoes, :tempo_total_ms, :integer, null: false, default: 0
  end
end
