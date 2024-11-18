# -------- Módulo Grafica --------

defmodule Grafica do
  @moduledoc """
  Módulo de red distribuida para implementar consenso y elección de líder.
  """

  @doc """
  Inicia un nodo con el estado inicial especificado.
  """
  def inicia(estado_inicial \\ %{:visitado => false, :id => -1, :lider => nil, :vecinos => [], :valor => nil}) do
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

  @doc """
  Procesa el mensaje de asignación de ID, lista de sus vecinos, valor propuesto, consenso.
  """
  def procesa_mensaje({:id, id}, estado) when is_integer(id) do
    IO.puts("Proceso con PID #{inspect(self())}: Recibí mi ID #{id}")
    estado = Map.put(estado, :id, id)
    {:ok, estado}
  end

  def procesa_mensaje({:vecinos, vecinos}, estado) when is_list(vecinos) do
    IO.puts("Proceso con PID #{inspect(self())}: Recibí mis vecinos: #{inspect(vecinos)}")
    estado = Map.put(estado, :vecinos, vecinos)
    {:ok, estado}
  end
  
  def procesa_mensaje({:proponer, valor}, estado) when is_integer(valor) do
    IO.puts("Proceso con PID #{inspect(self())}: Proponiendo valor #{valor}")
    estado = Map.put(estado, :valor, valor)
    propaga_valor(valor, estado[:vecinos])
    {:ok, estado}
  end

  def procesa_mensaje({:consensuar, valor_recibido}, estado) when is_integer(valor_recibido) do
    IO.puts("Proceso con PID #{inspect(self())}: Recibí valor para consensuar #{valor_recibido}")
    valor_actual = estado[:valor] || valor_recibido
    # -- Criterio para el consenso
    nuevo_valor = min(valor_actual, valor_recibido)
    estado = Map.put(estado, :valor, nuevo_valor)
    {:ok, estado}
  end

  def procesa_mensaje({:comprobar}, estado) do
    IO.puts("Proceso con PID #{inspect(self())}: Valor consensuado final es #{estado[:valor]}")
    {:ok, estado}
  end

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

  def procesa_mensaje({:inicia}, estado) do
    IO.puts("Proceso con PID #{inspect(self())}: Iniciando y propagando mi ID")
    %{:id => id, :vecinos => vecinos, :lider => lider} = estado
    lider = if lider == nil, do: id, else: lider
    estado = Map.put(estado, :lider, lider)
    propaga_lider(lider, vecinos, id)
    {:ok, estado}
  end

  def procesa_mensaje({:ya}, estado) do
    %{:id => id, :lider => lider} = estado
    if lider == id do
      IO.puts("Proceso con ID #{id}: Soy el líder")
    else
      IO.puts("Proceso con ID #{id}: El líder es #{lider}")
    end
    {:ok, estado}
  end

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


# -------- Módulo para manejar nodos --------

defmodule Practica03 do
  @moduledoc """
  Módulo para manejar la creación y envío de mensajes a los nodos para consenso.
  """

  @doc """
  Genera `n` procesos del módulo `Grafica` y los devuelve en una lista.
  """
  def genera(n) when is_integer(n) and n > 0 do
    spawn_in_list(n, Grafica, :inicia, [])
  end

  @doc """
  Crea `n` procesos usando el módulo y la función especificados y los almacena en una lista.
  """
  def spawn_in_list(n, modulo, funcion, args) when is_integer(n) do
    case n do
      0 -> []
      _ -> [spawn(modulo, funcion, args) | spawn_in_list(n - 1, modulo, funcion, args)]
    end
  end

  @doc """
  Envía un mensaje particular a todos los procesos de una lista.
  """
  def send_msg(lista, mensaje) when is_list(lista) do
    Enum.each(lista, fn proceso -> send(proceso, mensaje) end)
  end
end

# --------end--------
