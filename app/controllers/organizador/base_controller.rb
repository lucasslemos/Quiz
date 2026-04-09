class Organizador::BaseController < ApplicationController
  before_action :requer_organizador_aprovado!
end
