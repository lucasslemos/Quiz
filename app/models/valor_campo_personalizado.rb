class ValorCampoPersonalizado < ApplicationRecord
  belongs_to :participacao
  belongs_to :campo_personalizado
end
