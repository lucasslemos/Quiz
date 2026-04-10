class Organizador::CamposPersonalizadosController < Organizador::BaseController
  before_action :carregar_quiz
  before_action :carregar_campo, only: %i[edit update destroy]

  def new
    @campo = @quiz.campos_personalizados.new(posicao: proxima_posicao, tipo_campo: "text")
  end

  def create
    @campo = @quiz.campos_personalizados.new(campo_params)
    @campo.posicao ||= proxima_posicao

    if @campo.save
      redirect_to organizador_quiz_path(@quiz), notice: "Campo personalizado criado."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @campo.update(campo_params)
      redirect_to organizador_quiz_path(@quiz), notice: "Campo atualizado."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @campo.destroy
    redirect_to organizador_quiz_path(@quiz), notice: "Campo removido."
  end

  private

  def carregar_quiz
    @quiz = current_organizador.quizzes.find(params[:quiz_id])
  end

  def carregar_campo
    @campo = @quiz.campos_personalizados.find(params[:id])
  end

  def campo_params
    permitido = params.require(:campo_personalizado).permit(:rotulo, :tipo_campo, :obrigatorio, :posicao, :opcoes_texto)
    raw_opcoes = permitido.delete(:opcoes_texto)
    if permitido[:tipo_campo] == "select"
      permitido[:opcoes] = raw_opcoes.to_s.split("\n").map(&:strip).reject(&:blank?)
    else
      permitido[:opcoes] = nil
    end
    permitido
  end

  def proxima_posicao
    (@quiz.campos_personalizados.maximum(:posicao) || -1) + 1
  end
end
