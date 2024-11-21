defmodule Grafica do
  @moduledoc """
  Módulo de red distribuida para implementar consenso y elección de líder.
  """

  @doc """
  Inicia un nodo con el estado inicial especificado.
  """
  def inicia(estado_inicial) do
    Process.put(:estado_inicial, estado_inicial)
    IO.puts("Proceso con PID #{inspect(self())}: Nodo iniciado con estado #{inspect(estado_inicial)}")
    recibe_mensaje(estado_inicial)
  end

  defp valida_bloque(bloque, %{blockchain: blockchain}) do
    last_block = List.last(blockchain.chain)
    Block.valid?(bloque, last_block)
  end

  @doc """
  Procesa mensajes, diferenciando nodos bizantinos de nodos honestos.
  """
  def recibe_mensaje(estado) do
    receive do
      {:propuesta, pid_origen, bloque} ->
        IO.puts("Nodo #{inspect(self())} recibió una propuesta de #{inspect(pid_origen)}")

        if valida_bloque(bloque, estado) do
          IO.puts("Nodo #{inspect(self())}: Propuesta válida. Actualizando bloque actual.")
          estado = Map.put(estado, :bloque_actual, bloque)  # Actualizar el bloque actual

          # Enviar mensaje de preparación a los vecinos
          Enum.each(estado[:vecinos], fn vecino ->
            send(vecino, {:prepare, self(), bloque})
          end)
        else
          IO.puts("Nodo #{inspect(self())}: Propuesta inválida. Ignorando.")
        end
        recibe_mensaje(estado)

      {:prepare, pid_origen, bloque} ->
        IO.puts("Nodo #{inspect(self())} recibió un PREPARE de #{inspect(pid_origen)} para el bloque #{inspect(bloque)}")

        if Enum.member?(estado[:vecinos], pid_origen) do
          if valida_bloque(bloque, estado) do
            IO.puts("Nodo #{inspect(self())}: PREPARE válido. Actualizando bloque actual.")
            estado = Map.put(estado, :bloque_actual, bloque)  # Actualizar el bloque actual
            IO.puts("Nodo #{inspect(self())} estado actualizado: #{inspect(estado)}")
            # Enviar voto positivo al origen
            send(pid_origen, {:voto, self(), true})
          else
            IO.puts("Nodo #{inspect(self())}: PREPARE inválido. Enviando voto negativo.")
            send(pid_origen, {:voto, self(), false})
          end
        else
          IO.puts("Error: Nodo #{inspect(pid_origen)} no es un vecino conocido")
        end
        recibe_mensaje(estado)

      {:voto, pid_origen, voto_valido} ->
        IO.puts("Nodo #{inspect(self())} estado actualizado: #{inspect(estado)}")
        IO.puts("Nodo #{inspect(self())} recibió un voto #{voto_valido} de #{inspect(pid_origen)}")

        votos = Map.update(estado[:votos], voto_valido, [pid_origen], fn lista -> [pid_origen | lista] end)
        estado = Map.put(estado, :votos, votos)

        IO.puts("Nodo #{inspect(self())}: Votos actuales: #{inspect(votos)} para el bloque #{inspect(estado[:bloque_actual])}")

        # Revisar si hay quórum
        if estado[:bloque_actual] and length(Map.get(votos, true, [])) > div(length(estado[:vecinos]), 2) do
          IO.puts("Nodo #{inspect(self())}: Quórum alcanzado para el bloque #{inspect(estado[:bloque_actual])}")
          # Realizar las acciones necesarias tras alcanzar el quórum
        end
        # Pasar el estado actualizado a la siguiente llamada
        recibe_mensaje(estado)


      {:commit, bloque} ->
        IO.puts("Nodo #{inspect(self())} recibió un COMMIT para el bloque #{inspect(bloque)}")

        votos = Map.get(estado, :votos_commit, %{})
        votos = Map.update(votos, bloque, 1, &(&1 + 1))
        estado = Map.put(estado, :votos_commit, votos)

        if Map.get(votos, bloque, 0) > div(length(estado[:vecinos]) * 2, 3) do
          IO.puts("Nodo #{inspect(self())}: Quórum alcanzado en COMMIT. Añadiendo bloque a la blockchain.")
          {new_blockchain, nuevo_bloque_actual} =
            Blockchain.insert_and_return_block(estado[:blockchain], bloque)

          estado =
            estado
            |> Map.put(:blockchain, new_blockchain)
            |> Map.put(:bloque_actual, nuevo_bloque_actual)
        end

        recibe_mensaje(estado)

      {:vecinos, vecinos} ->
        IO.puts("Nodo #{inspect(self())} actualizando vecinos: #{inspect(vecinos)}")
        estado = Map.put(estado, :vecinos, vecinos)
        IO.puts("Nodo #{inspect(self())} estado actualizado: #{inspect(estado)}")
        recibe_mensaje(estado)

      {:nuevo_bloque, data} ->
        {blockchain_actualizada, nuevo_bloque} = Blockchain.insert_and_return_block(estado.blockchain, data)
        estado = Map.put(estado, :blockchain, blockchain_actualizada)
        estado = Map.put(estado, :bloque_actual, nuevo_bloque)

        IO.puts("Nodo #{inspect(self())}: Bloque #{inspect(nuevo_bloque)} insertado en la blockchain.")

        # Propagar propuesta a los vecinos
        Enum.each(estado.vecinos, fn vecino ->
          send(vecino, {:propuesta, self(), nuevo_bloque})
        end)

        recibe_mensaje(estado)


      # _ ->
      #   IO.puts("Proceso con PID #{inspect(self())}: Recibí un mensaje desconocido")
      #   recibe_mensaje(estado)
    end
  end
end
