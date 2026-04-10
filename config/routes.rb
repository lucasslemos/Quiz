Rails.application.routes.draw do
  # ----------------------------------------------------------------------------
  # Saúde
  # ----------------------------------------------------------------------------
  get "up" => "rails/health#show", as: :rails_health_check

  # ----------------------------------------------------------------------------
  # Autenticação do organizador
  # ----------------------------------------------------------------------------
  get  "/cadastro", to: "cadastros#new",     as: :cadastro
  post "/cadastro", to: "cadastros#create"

  get    "/entrar", to: "sessoes#new",     as: :entrar
  post   "/entrar", to: "sessoes#create"
  delete "/sair",   to: "sessoes#destroy", as: :sair

  get   "/senha/nova",    to: "senhas#new",    as: :nova_senha
  post  "/senha",         to: "senhas#create", as: :senhas
  get   "/senha/editar",  to: "senhas#edit",   as: :editar_senha
  patch "/senha",         to: "senhas#update"

  get "/aguardando-aprovacao", to: "aprovacoes#show", as: :aguardando_aprovacao

  # ----------------------------------------------------------------------------
  # Área do organizador (logado e aprovado)
  # ----------------------------------------------------------------------------
  namespace :organizador do
    get "/", to: "painel#show", as: :root

    resources :quizzes do
      resources :perguntas, except: %i[index show]
      resources :campos_personalizados, except: %i[index show]
      resources :campanhas do
        member do
          post :ativar
          post :encerrar
        end
        resource :qr_code, only: %i[show]
        resources :participacoes, only: %i[index] do
          collection do
            get :vencedores
            get :ranking_ao_vivo
          end
        end
      end
    end
  end

  # ----------------------------------------------------------------------------
  # Área pública (participante)
  # ----------------------------------------------------------------------------
  get  "/c/:slug",            to: "publico/campanhas#show",                as: :publico_campanha
  post "/c/:slug/iniciar",    to: "publico/campanhas#iniciar_participacao", as: :publico_campanha_iniciar
  get  "/c/:slug/responder",           to: "publico/campanhas#responder",           as: :publico_campanha_responder
  get  "/c/:slug/pergunta/:numero",  to: "publico/campanhas#pergunta",            as: :publico_campanha_pergunta
  post "/c/:slug/pergunta/:numero",  to: "publico/campanhas#responder_pergunta",  as: :publico_campanha_responder_pergunta
  get  "/c/:slug/resultado",         to: "publico/campanhas#resultado",           as: :publico_campanha_resultado

  # ----------------------------------------------------------------------------
  # Painel do administrador
  # ----------------------------------------------------------------------------
  namespace :admin do
    get    "/entrar", to: "sessoes#new",     as: :entrar
    post   "/entrar", to: "sessoes#create"
    delete "/sair",   to: "sessoes#destroy", as: :sair

    get "/", to: redirect("/admin/organizadores")

    resources :organizadores, only: %i[index] do
      collection do
        get :pendentes
      end
      member do
        post :aprovar
        post :rejeitar
        post :suspender
      end
    end
  end

  # ----------------------------------------------------------------------------
  # Raiz da aplicação
  # ----------------------------------------------------------------------------
  root to: "sessoes#new"
end
