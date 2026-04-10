module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_organizador

    def connect
      self.current_organizador = find_organizador
    end

    private

    def find_organizador
      if (id = request.session[:organizador_id])
        Organizador.find_by(id: id)
      end
    end
  end
end
