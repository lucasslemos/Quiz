class Admin::BaseController < ApplicationController
  include AutenticacaoAdministrador

  layout "admin"
  before_action :requer_administrador!
end
