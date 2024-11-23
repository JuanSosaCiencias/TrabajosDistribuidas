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
end

# --------end --------
