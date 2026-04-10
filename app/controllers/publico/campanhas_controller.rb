class Publico::CampanhasController < ApplicationController
  layout "participante"

  before_action :carregar_campanha

  COOKIE_TOKEN = :token_participante_quiz
  COOKIE_TTL = 1.year

  def show
    case @campanha.status
    when "draft"
      render :nao_disponivel, status: :forbidden
    when "closed"
      render :encerrada, status: :gone
    else
      @participacao = participacao_do_cookie
      if @participacao
        redirect_to acao_responder_path
      else
        @campos_personalizados = @quiz.campos_personalizados
      end
    end
  end

  def iniciar_participacao
    return render :nao_disponivel, status: :forbidden unless @campanha.active?

    if VerificadorParticipacaoDuplicada.duplicada?(@campanha,
        cookie_token: cookies[COOKIE_TOKEN],
        email: params.dig(:participacao, :email),
        telefone: params.dig(:participacao, :telefone))
      render :ja_participou, status: :forbidden
      return
    end

    participacao = @campanha.participacoes.new(participacao_params)
    valores_personalizados_params.each do |campo_id, valor|
      participacao.valores_campo_personalizado.build(campo_personalizado_id: campo_id, valor: valor)
    end

    if participacao.save
      cookies.encrypted[COOKIE_TOKEN] = {
        value: participacao.token_participante,
        httponly: true,
        expires: COOKIE_TTL.from_now,
        same_site: :lax
      }
      redirect_to publico_campanha_responder_path(@campanha.slug)
    else
      @participacao = participacao
      @campos_personalizados = @quiz.campos_personalizados
      render :show, status: :unprocessable_content
    end
  end

  def responder
    @participacao = participacao_do_cookie
    return redirect_to publico_campanha_path(@campanha.slug) unless @participacao
    return redirect_to publico_campanha_resultado_path(@campanha.slug) if @participacao.enviado_em.present?

    @perguntas = @quiz.perguntas.includes(:opcoes_resposta)
  end

  def enviar_respostas
    @participacao = participacao_do_cookie
    return redirect_to publico_campanha_path(@campanha.slug) unless @participacao
    return redirect_to publico_campanha_resultado_path(@campanha.slug) if @participacao.enviado_em.present?

    perguntas = @quiz.perguntas.includes(:opcoes_resposta).to_a
    respostas_params = params.require(:respostas).to_unsafe_h

    Participacao.transaction do
      perguntas.each do |pergunta|
        opcao_id = respostas_params[pergunta.id.to_s].to_i
        opcao = pergunta.opcoes_resposta.find { |o| o.id == opcao_id }
        next unless opcao

        @participacao.respostas.create!(pergunta: pergunta, opcao_resposta: opcao)
      end

      acertos = @participacao.respostas.joins(:opcao_resposta).where(opcoes_resposta: { correta: true }).count
      @participacao.update!(
        pontuacao: acertos,
        vencedor: (acertos == perguntas.size && perguntas.any?),
        enviado_em: Time.current
      )
    end

    redirect_to publico_campanha_resultado_path(@campanha.slug)
  end

  def resultado
    @participacao = participacao_do_cookie
    return redirect_to publico_campanha_path(@campanha.slug) unless @participacao
  end

  private

  def carregar_campanha
    @campanha = Campanha.find_by!(slug: params[:slug])
    @quiz = @campanha.quiz
  rescue ActiveRecord::RecordNotFound
    render :nao_encontrada, status: :not_found
  end

  def participacao_do_cookie
    token = cookies.encrypted[COOKIE_TOKEN]
    return nil if token.blank?

    @campanha.participacoes.find_by(token_participante: token)
  end

  def participacao_params
    params.require(:participacao).permit(:nome, :email, :telefone)
  end

  def valores_personalizados_params
    raw = params.dig(:participacao, :campos_personalizados)
    return {} if raw.blank?

    raw.respond_to?(:to_unsafe_h) ? raw.to_unsafe_h : raw.to_h
  end

  def acao_responder_path
    publico_campanha_responder_path(@campanha.slug)
  end
end
