class Organizador::CampanhasController < Organizador::BaseController
  before_action :carregar_quiz
  before_action :carregar_campanha, only: %i[show edit update destroy ativar encerrar]

  def index
    @campanhas = @quiz.campanhas.order(created_at: :desc)
  end

  def new
    @campanha = @quiz.campanhas.new
  end

  def create
    @campanha = @quiz.campanhas.new(campanha_params)
    if @campanha.save
      redirect_to organizador_quiz_campanha_path(@quiz, @campanha), notice: "Campanha criada."
    else
      render :new, status: :unprocessable_content
    end
  end

  def show
    respond_to do |format|
      format.html
      format.csv do
        exportador = ExportadorCsvCampanha.new(@campanha)
        send_data exportador.gerar, type: "text/csv", filename: exportador.nome_arquivo
      end
    end
  end

  def edit
  end

  def update
    permitidos = campanha_params
    if @campanha.tem_participacoes?
      permitidos = permitidos.except(:slug)
    end

    if @campanha.update(permitidos)
      redirect_to organizador_quiz_campanha_path(@quiz, @campanha), notice: "Campanha atualizada."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @campanha.destroy
    redirect_to organizador_quiz_path(@quiz), notice: "Campanha excluída."
  end

  def ativar
    @campanha.ativar!
    redirect_to organizador_quiz_campanha_path(@quiz, @campanha), notice: "Campanha ativada."
  end

  def encerrar
    @campanha.encerrar!
    redirect_to organizador_quiz_campanha_path(@quiz, @campanha), notice: "Campanha encerrada."
  end

  private

  def carregar_quiz
    @quiz = current_organizador.quizzes.find(params[:quiz_id])
  end

  def carregar_campanha
    @campanha = @quiz.campanhas.find(params[:id])
  end

  def campanha_params
    params.require(:campanha).permit(:nome, :slug, :inicio_em, :fim_em)
  end
end
