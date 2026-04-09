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
  end

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
