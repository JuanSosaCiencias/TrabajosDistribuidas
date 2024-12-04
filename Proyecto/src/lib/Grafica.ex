# -------- Módulo Grafica --------

defmodule Grafica do
  @moduledoc """
  Módulo de red distribuida para implementar consenso y elección de líder.
  """

  @doc """
  Inicia un nodo con el estado inicial especificado.
  """
  def inicia(estado_inicial \\ %{
      :lider => nil,
      :vecinos => [],
      :blockchain => Blockchain.new(),
      :bizantino => false,
      :mensajes => %{:prepare => [], :commit => []}
    }) do
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
    IO.puts("Proceso con PID #{inspect(self())}: Estado actual: #{inspect(estado[:blockchain])}")
    estado = reiniciar_mensajes_y_vistos(estado)
    {:ok, estado}
  end


  # Al darle este mensaje al nodo nos imprime sus vecinos y se los asigna.
  def procesa_mensaje({:vecinos, vecinos}, estado) when is_list(vecinos) do
    IO.puts("Proceso con PID #{inspect(self())}: Recibí mis vecinos: #{inspect(vecinos)}")
    estado = Map.put(estado, :vecinos, vecinos)
    {:ok, estado}
  end

  def procesa_mensaje({:lider,lider},estado) do
     IO.puts("Proceso con PID #{inspect(self())}: Recibí al lider: #{inspect(lider)}")
    estado = Map.put(estado, :lider, lider)
    {:ok,estado}
  end

  #### Codigo para el pBFT


  def procesa_mensaje({:bloque, bloque}, estado) do
      # Fase Pre-Prepare: el líder envía el bloque a los vecinos
      IO.puts("Proceso #{inspect(self())}: Soy el líder, iniciando Pre-Prepare con bloque #{inspect(bloque)}")
      Enum.each(estado[:vecinos], fn vecino ->
        send(vecino, {:preprepare, bloque, inspect(self())})
      end)
    {:ok, estado}
  end

  def procesa_mensaje({:preprepare, bloque, lider_id}, estado) do
    IO.puts("Proceso #{inspect(self())}: Recibí Pre-Prepare de #{lider_id} con bloque #{inspect(bloque)}")
    if Block.valid?(bloque) do
      Enum.each(estado[:vecinos], fn vecino ->
        send(vecino, {:prepare, bloque, inspect(self())})
      end)
      estado = actualizar_mensajes(estado, :prepare, {bloque, inspect(self())})
      {:ok, estado}
    else
      IO.puts("Proceso #{inspect(self())}: Bloque inválido, ignorando Pre-Prepare.")
      {:ok, estado}
    end
  end

  def procesa_mensaje({:prepare, bloque, nodo_id} = mensaje, estado) do
    if not mensaje_visto?(estado, mensaje) do
      IO.puts("Proceso #{inspect(self())}: Recibí Prepare de #{nodo_id}")
      estado = actualizar_mensajes(estado, :prepare, {bloque, nodo_id})
      estado = marcar_mensaje_visto(estado, mensaje)

      # Forward message to help propagation in incomplete graphs
      Enum.each(estado[:vecinos], fn vecino ->
        send(vecino, mensaje)
      end)

      if suficiente_cuorum?(estado, :prepare) do
        IO.puts("Proceso #{inspect(self())}: Cuórum de Prepare alcanzado, enviando Commit")
        Enum.each(estado[:vecinos], fn vecino ->
          send(vecino, {:commit, bloque, inspect(self())})
        end)
        estado = actualizar_mensajes(estado, :commit, {bloque, inspect(self())})
      end

      {:ok, estado}
    else
      {:ok, estado}
    end
  end

  def procesa_mensaje({:commit, bloque, nodo_id} = mensaje, estado) do
    if not mensaje_visto?(estado, mensaje) do
      IO.puts("Proceso #{inspect(self())}: Recibí Commit de #{nodo_id}")
      estado = actualizar_mensajes(estado, :commit, {bloque, nodo_id})
      estado = marcar_mensaje_visto(estado, mensaje)

      # Forward message to help propagation in incomplete graphs
      Enum.each(estado[:vecinos], fn vecino ->
      send(vecino, mensaje)
      end)


      IO.puts("Proceso #{inspect(self())}: Cuórum de Commit alcanzado, agregando bloque a la blockchain")
      estado = agregar_bloque(bloque, estado)


      {:ok, estado}
    else
      {:ok, estado}
    end
  end

  defp reiniciar_mensajes_y_vistos(estado) do
    IO.puts("Proceso #{inspect(self())}: Reiniciando mensajes y mensajes vistos para un nuevo consenso.")
    estado
    |> Map.put(:mensajes, %{:prepare => [], :commit => []})
    |> Map.put(:mensajes_vistos, MapSet.new())
  end


  defp actualizar_mensajes(estado, tipo, mensaje) do
    mensajes_actualizados = Map.update(estado[:mensajes], tipo, [mensaje], &[mensaje | &1])
    Map.put(estado, :mensajes, mensajes_actualizados)
  end

  defp suficiente_cuorum?(estado, tipo) do
    mensajes = Map.get(estado[:mensajes], tipo, [])
    unique_mensajes = Enum.uniq_by(mensajes, fn {bloque, _} -> bloque end)
    total_nodos = length(estado[:vecinos]) + 1
    threshold = div(2 * total_nodos, 3) + 1

    IO.puts("Proceso #{inspect(self())}: Mensajes únicos: #{inspect(unique_mensajes)}, threshold: #{threshold}")
    length(unique_mensajes) < threshold
  end

  defp agregar_bloque(bloque, estado) do
    case Blockchain.insert(bloque, estado[:blockchain]) do
      {:ok, blockchain_actualizada} ->
        IO.puts("Proceso #{inspect(self())}: Bloque agregado exitosamente.")
        Map.put(estado, :blockchain, blockchain_actualizada)

      {:error, motivo} ->
        IO.puts("Proceso #{inspect(self())}: Error al agregar el bloque: #{motivo}")
        estado
    end
  end


  # Helper functions for message deduplication
  defp mensaje_visto?(estado, mensaje) do
    vistos = Map.get(estado, :mensajes_vistos, MapSet.new())
    MapSet.member?(vistos, mensaje)
  end

  defp marcar_mensaje_visto(estado, mensaje) do
    vistos = Map.get(estado, :mensajes_vistos, MapSet.new())
    Map.put(estado, :mensajes_vistos, MapSet.put(vistos, mensaje))
  end

end

# --------end --------
