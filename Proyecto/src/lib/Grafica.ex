# -------- Módulo Grafica --------

defmodule Grafica do
  @moduledoc """
  Módulo de red distribuida para implementar consenso y elección de líder.
  """

  @doc """
  Inicia un nodo con el estado inicial especificado.
  """
  def inicia(estado_inicial \\ %{:lider => nil, :vecinos => [], :blockchain => nil, :bizantino => false}) do
    IO.puts("Proceso con PID #{inspect(self())}: Iniciando con estado #{inspect(estado_inicial)}")
    recibe_mensaje(estado_inicial)
  end

  @doc """
  Recibe y procesa mensajes, actualizando el estado del nodo.
  """
  def recibe_mensaje(estado) do
    receive do
      mensaje ->
        {:ok, nuevo_estado} = procesa_mensaje(mensaje, estado)
        recibe_mensaje(nuevo_estado)
    end
  end

  #  Al darle este mensaje al nodo nos imprime su estado actual.
  def procesa_mensaje({:estado, _}, estado) do
    IO.puts("Proceso con PID #{inspect(self())}: Estado actual: #{inspect(estado)}")
    {:ok, estado}
  end


  # Al darle este mensaje al nodo nos imprime sus vecinos y se los asigna.
  def procesa_mensaje({:vecinos, vecinos}, estado) when is_list(vecinos) do
    IO.puts("Proceso con PID #{inspect(self())}: Recibí mis vecinos: #{inspect(vecinos)}")
    estado = Map.put(estado, :vecinos, vecinos)
    {:ok, estado}
  end

  # Al darle este mensaje al nodo nos imprime el bloque y lo agrega a la blockchain.

  # NOTA: Aun no tiene implementado el consenso ni validacion de bloques o blockchain.
  def procesa_mensaje({:bloque, block}, estado) do
    IO.puts("Proceso con PID #{inspect(self())}: Recibí un bloque: #{inspect(block)}")
    # Agregamos el bloque a la blockchain del nodo
    nueva_blockchain = %Blockchain{
      chain: estado.blockchain.chain ++ [block]
    }
    estado = Map.put(estado, :blockchain, nueva_blockchain)
    {:ok, estado}
  end

  # Cambiar esta funcion para que en vez de ser valor sea un bloques
  def procesa_mensaje({:proponer, valor}, estado) when is_integer(valor) do
    IO.puts("Proceso con PID #{inspect(self())}: Proponiendo valor #{valor}")
    estado = Map.put(estado, :valor, valor)
    propaga_valor(valor, estado[:vecinos])
    {:ok, estado}
  end

  # Igual cambiar esta funcion para que en vez de ser valor sea un bloques
  def procesa_mensaje({:consensuar, valor_recibido}, estado) when is_integer(valor_recibido) do
    IO.puts("Proceso con PID #{inspect(self())}: Recibí valor para consensuar #{valor_recibido}")
    valor_actual = estado[:valor] || valor_recibido
    # -- Criterio para el consenso
    nuevo_valor = min(valor_actual, valor_recibido)
    estado = Map.put(estado, :valor, nuevo_valor)
    {:ok, estado}
  end

  #  Aqui estamos propagando el lider deberia ser propagar el bloque
  def procesa_mensaje({:mensaje, n_id}, estado) when is_integer(n_id) do
    IO.puts("Proceso con PID #{inspect(self())}: Recibí mensaje de mi vecino con ID #{n_id}")
    %{:id => id, :lider => lider_actual} = estado

    if n_id < (lider_actual || id) do
      IO.puts("Proceso con ID #{id}: Actualizando líder a #{n_id}")
      estado = Map.put(estado, :lider, n_id)
      propaga_lider(n_id, estado[:vecinos], id)
      {:ok, estado}
    else
      {:ok, estado}
    end
  end

  #  Aqui usabamos para propagar el id pero ahora no se si es necesario, quizas cambiar por iniciar que recibe un bloque y lo propaga
  # def procesa_mensaje({:inicia}, estado) do
  #   IO.puts("Proceso con PID #{inspect(self())}: Iniciando y propagando mi ID")
  #   %{:id => id, :vecinos => vecinos, :lider => lider} = estado
  #   lider = if lider == nil, do: id, else: lider
  #   estado = Map.put(estado, :lider, lider)
  #   propaga_lider(lider, vecinos, id)
  #   {:ok, estado}
  # end

  # Propaga el valor propuesto a todos los vecinos para el consenso.
  defp propaga_valor(valor, vecinos) when is_list(vecinos) do
    Enum.each(vecinos, fn vecino -> send(vecino, {:consensuar, valor}) end)
  end

  # Propaga el líder propuesto a todos los vecinos.
  defp propaga_lider(nuevo_lider, vecinos, _id) when is_integer(nuevo_lider) and is_list(vecinos) do
    Enum.each(vecinos ++ [self()], fn vecino -> send(vecino, {:mensaje, nuevo_lider}) end)
  end
end

# --------end --------
