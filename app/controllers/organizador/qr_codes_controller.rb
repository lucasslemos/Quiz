class Organizador::QrCodesController < Organizador::BaseController
  before_action :carregar_campanha

  def show
    @url_publica = url_publica
    respond_to do |format|
      format.html
      format.svg  { render plain: GeradorQrCode.svg_para(@url_publica), content_type: "image/svg+xml" }
      format.png do
        send_data GeradorQrCode.png_para(@url_publica).to_s,
                  type: "image/png",
                  filename: "qr-#{@campanha.slug}.png",
                  disposition: "attachment"
      end
    end
  end

  private

  def carregar_campanha
    @quiz = current_organizador.quizzes.find(params[:quiz_id])
    @campanha = @quiz.campanhas.find(params[:campanha_id])
  end

  def url_publica
    Rails.application.routes.url_helpers.publico_campanha_url(
      slug: @campanha.slug,
      host: request.host_with_port,
      protocol: request.protocol
    )
  end
end
