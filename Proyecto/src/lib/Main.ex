# -------- Módulo Main --------
defmodule Main do
  @moduledoc """
  Módulo principal que maneja la creación de la red de nodos, incluyendo procesos honestos y bizantinos,
  y simula la blockchain distribuida.
  """

  def run(n, f) when is_integer(n) and is_integer(f) and n > 3 * f do
    IO.puts("Iniciando la red con #{n} nodos, incluyendo #{f} procesos bizantinos...")

    # 1. Crear nodos
    procesos = crea_nodos(n, f)

    Process.sleep(1000)
    IO.puts("----------------")
    IO.puts("Nodos creados con éxito. Asignando vecinos...")
    IO.puts("----------------")

    # 2. Asignar vecinos
    vecinos = asigna_vecinos(procesos)

    Process.sleep(1000)
    IO.puts("----------------")
    IO.puts("Vecinos asignados con éxito. Creando la blockchain...")
    IO.puts("----------------")

    # 3. Crear blockchain inicial
    blockchain = Blockchain.new()

    IO.puts("----------------")
    IO.puts("Blockchain inicial creada. Ejecutando PBFT...")
    IO.puts("----------------")

    # 4. Asignar el estado inicial a los nodos
    Enum.each(procesos, fn proceso ->
      send(proceso, {:estado_inicial, %{
        blockchain: blockchain,           # Asumiendo que blockchain está definido en otro lugar
        vecinos: [],                      # Lista vacía de vecinos por defecto
        bizantino: false                  # Valor de 'false' para nodo honesto
      }})
    end)



    # 5. Seleccionar líder honesto
    lider = seleccionar_lider_honesto(procesos)

    if lider == nil do
      IO.puts("Error: No se pudo seleccionar un líder honesto.")
      blockchain
    end

    IO.puts("Líder seleccionado: #{inspect(lider)}")

    # 6. Bloque propuesto por el líder
    prev_block = List.last(blockchain.chain)
    bloque_propuesto = Block.new("Bloque propuesto por el nodo líder", prev_block.hash)

    # 7. Fase Pre-prepare: el líder propone el bloque a sus vecinos
    Enum.each(vecinos[lider], fn vecino ->
      send(vecino, {:propuesta, lider, bloque_propuesto})
    end)

    # 8. Fase Prepare: los nodos votan por el bloque
    votos = realiza_prepare(procesos, bloque_propuesto, vecinos)

    IO.inspect(votos)  # Verifica qué tipo de estructura tiene 'votos'

    # 9. Fase Commit: los nodos acuerdan añadir el bloque si hay suficientes votos
    if map_size(votos) >= (2 * f + 1) do
      IO.puts("Suficientes votos recibidos. Añadiendo el bloque a la blockchain.")
      blockchain = Blockchain.insert(blockchain, bloque_propuesto.data)
    else
      IO.puts("No se alcanzó consenso. Bloque rechazado.")
    end

    IO.puts("----------------")
    IO.puts("Proceso PBFT completado. Estado final de la blockchain:")
    IO.inspect(blockchain.chain)

    blockchain
  end

  defp crea_nodos(n, f) do
    # Crear `f` procesos bizantinos y `n - f` procesos honestos
    bizantinos = for _ <- 1..f, do: spawn(NodoBizantino, :inicia, [])
    honestos = for _ <- (f + 1)..n, do: spawn(NodoHonesto, :inicia, [])

    bizantinos ++ honestos
  end

  defp asigna_vecinos(procesos) do
    n = length(procesos)
    k = max(4, div(n, 3))  # Aumentar la cantidad de vecinos, mínimo 4

    # Crear un mapa base de vecinos para cada nodo
    vecinos_base =
      Enum.map(0..(n - 1), fn i ->
        vecinos =
          Enum.flat_map(1..div(k, 2), fn offset ->
            [
              Enum.at(procesos, rem(i + offset, n)),
              Enum.at(procesos, rem(i - offset + n, n))
            ]
          end)
          |> Enum.uniq()  # Evitar duplicados

        {Enum.at(procesos, i), vecinos}
      end)
      |> Enum.into(%{})

    # Asegurar que las relaciones sean bidireccionales
    vecinos_bidireccionales =
      Enum.reduce(vecinos_base, vecinos_base, fn {nodo, lista_vecinos}, acc ->
        Enum.reduce(lista_vecinos, acc, fn vecino, acc2 ->
          Map.update(acc2, vecino, [nodo], fn v -> Enum.uniq([nodo | v]) end)
        end)
      end)

    # Asignar vecinos randomizados para simular conexiones impredecibles
    vecinos_random =
      Enum.map(procesos, fn nodo ->
        {nodo, Enum.shuffle(vecinos_bidireccionales[nodo])}
      end)
      |> Enum.into(%{})

    # Enviar los vecinos a cada proceso
    Enum.each(procesos, fn nodo ->
      send(nodo, {:vecinos, vecinos_random[nodo]})
    end)

    vecinos_random
  end


  defp seleccionar_lider_honesto(procesos) do
    Enum.find(procesos, &!bizantino?(&1))
  end

  defp bizantino?(nodo) do
    case Process.info(nodo, :dictionary) do
      {:dictionary, dictionary} ->
        estado_inicial = dictionary[:estado_inicial]

        if estado_inicial do
          estado_inicial[:bizantino] == true
        else
          false
        end

      _ ->
        false
    end
  end

  defp realiza_prepare(procesos, bloque_propuesto, _vecinos) do
    # Enviar bloque propuesto a todos los nodos
    # Enum.each(procesos, fn nodo ->
    #   send(nodo, {:propuesta, self(), bloque_propuesto})
    # end)

    # Recoger votos de los nodos
    # votos = Enum.reduce(procesos, %{}, fn _nodo, votos_acumulados ->
    #   receive do
    #     {:voto, pid, voto_valido} ->
    #       IO.puts("Voto recibido del nodo #{inspect(pid)}: #{voto_valido}")
    #       Map.update(votos_acumulados, voto_valido, [pid], &[pid | &1])
    #   after
    #     1000 -> votos_acumulados
    #   end
    # end)

    # # Retornar los votos recolectados
    # votos
  end
end

# -------- Módulo NodoHonesto --------
defmodule NodoHonesto do
  def inicia(vecinos \\ []) do
    Grafica.inicia(%{
      vecinos: vecinos,               # Lista de PIDs de vecinos
      bizantino: false,               # Nodo honesto
      blockchain: Blockchain.new(),   # Inicializa blockchain vacío o existente
      bloque_actual: nil,             # No hay bloque en propuesta al inicio
      votos: %{}                      # Mapa vacío para registrar votos
    })
  end
end

# -------- Módulo NodoBizantino --------
defmodule NodoBizantino do
  def inicia(vecinos \\ []) do
    Grafica.inicia(%{
      vecinos: vecinos,               # Lista de PIDs de vecinos
      bizantino: true,                # Nodo bizantino
      blockchain: Blockchain.new(),   # Inicializa blockchain vacío o existente
      bloque_actual: nil,             # No hay bloque en propuesta al inicio
      votos: %{}                      # Mapa vacío para registrar votos
    })
  end
end
# --------end--------
