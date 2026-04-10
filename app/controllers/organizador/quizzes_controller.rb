class Organizador::QuizzesController < Organizador::BaseController
  before_action :carregar_quiz, only: %i[show edit update destroy]

  def index
    @quizzes = current_organizador.quizzes.order(created_at: :desc)
  end

  def new
    @quiz = current_organizador.quizzes.new
  end

  def create
    @quiz = current_organizador.quizzes.new(quiz_params)
    if @quiz.save
      redirect_to organizador_quiz_path(@quiz), notice: "Quiz criado com sucesso."
    else
      render :new, status: :unprocessable_content
    end
  end

  def show
  end

  def edit
  end

  def update
    if @quiz.update(quiz_params)
      redirect_to organizador_quiz_path(@quiz), notice: "Quiz atualizado."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    # Confirmação dupla quando há campanhas com participações:
    # quando esses models existirem (seção 9), a checagem viva aqui.
    # Por enquanto delete direto — sem dependências para impedir.
    if confirmacao_dupla_necessaria? && params[:confirmar_exclusao].blank?
      redirect_to organizador_quiz_path(@quiz),
                  alert: "Este quiz tem participações associadas. Confirme novamente clicando em \"Excluir mesmo assim\"."
      return
    end

    @quiz.destroy
    redirect_to organizador_quizzes_path, notice: "Quiz excluído."
  end

  private

  def carregar_quiz
    @quiz = current_organizador.quizzes.find(params[:id])
  end

  def quiz_params
    params.require(:quiz).permit(:titulo, :email_state, :phone_state)
  end

  def confirmacao_dupla_necessaria?
    return false unless @quiz.respond_to?(:campanhas)

    @quiz.campanhas.joins(:participacoes).exists?
  end
end
