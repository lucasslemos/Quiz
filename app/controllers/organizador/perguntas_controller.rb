class Organizador::PerguntasController < Organizador::BaseController
  before_action :carregar_quiz
  before_action :carregar_pergunta, only: %i[edit update destroy]

  def new
    @pergunta = @quiz.perguntas.new(posicao: proxima_posicao)
    2.times { @pergunta.opcoes_resposta.build }
  end

  def create
    @pergunta = @quiz.perguntas.new(pergunta_params)
    @pergunta.posicao ||= proxima_posicao

    if @pergunta.save
      redirect_to organizador_quiz_path(@quiz), notice: "Pergunta criada."
    else
      garantir_campos_minimos
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @pergunta.update(pergunta_params)
      redirect_to organizador_quiz_path(@quiz), notice: "Pergunta atualizada."
    else
      garantir_campos_minimos
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @pergunta.destroy
    redirect_to organizador_quiz_path(@quiz), notice: "Pergunta removida."
  end

  private

  def carregar_quiz
    @quiz = current_organizador.quizzes.find(params[:quiz_id])
  end

  def carregar_pergunta
    @pergunta = @quiz.perguntas.find(params[:id])
  end

  def pergunta_params
    params.require(:pergunta).permit(
      :texto,
      :posicao,
      opcoes_resposta_attributes: %i[id texto correta posicao _destroy]
    )
  end

  def proxima_posicao
    (@quiz.perguntas.maximum(:posicao) || -1) + 1
  end

  def garantir_campos_minimos
    while @pergunta.opcoes_resposta.size < 2
      @pergunta.opcoes_resposta.build
    end
  end
end
