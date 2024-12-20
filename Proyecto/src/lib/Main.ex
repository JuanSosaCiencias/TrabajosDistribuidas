defmodule Main do
  @moduledoc """
  Módulo principal que maneja la creación de una red de nodos utilizando el modelo Watts y Strogatz. Incluye procesos honestos y bizantinos.
  Simula la blockchain distribuida con nodos que participan en el consenso a través de un algoritmo basado en Practical Byzantine Fault Tolerance.
  """

  @doc """
  Función principal que inicializa la red de `n` nodos y `f` procesos bizantinos.

  Además simula el consenso enviando bloques válidos e inválidos a través de la red.

   ## Parámetros:
  - `n`: El número total de nodos en la red.
  - `f`: El número de nodos bizantinos en la red.

   ## Retorna:
  La lista de los procesos para permitir la interacción manual.
  """
  def run(n, f) do
    IO.puts("\n\n Iniciando la red con #{n} nodos, incluyendo #{f} procesos bizantinos...\n ")

    procesos = crea_nodos(n, f)

    Process.sleep(1000)  # Esperar a que los nodos se inicialicen
    IO.puts("\n Nodos inicializados. Asignando vecinos... \n")

    asigna_vecinos(procesos)

    Process.sleep(1000)
    IO.puts("\n Vecinos asignados ... \n")

    # Se toma un proceso cualquiera para mandar el primer bloque
    ([h | _]) = procesos

    # Crear un nuevo bloque para enviar al proceso (válido)
    bloque = Block.new("Bloque valido", "2AF1E39")
    IO.puts("\n Creando un nuevo bloque: #{inspect(bloque)}\n")

    # Enviar el bloque al proceso
    Process.sleep(3000)
    IO.puts("\n Enviando bloque a un proceso...\n")
    send(h, {:bloque, bloque})

    # Esperar propagación
    Process.sleep(3000)
    IO.puts("\n Consenso según confirmado ... \n")

     # Verificar el estado de cada nodo
    IO.puts("\n Verificando estado final de los nodos...\n")
    Enum.each(procesos, fn pid -> send(pid, {:estado, nil}) end)

    Process.sleep(5000)
    # Crear un nuevo bloque para enviar al proceso (Invalido)
    bloque = Block.new("Bloque invalido", "6969696")
    IO.puts("\n Creando un nuevo bloque invalido: #{inspect(bloque)}\n")

    # Enviar el bloque al proceso
    Process.sleep(3000)
    IO.puts("\n Enviando bloque a un proceso...\n")
    send(h, {:bloque, bloque})

    # Esperar propagación
    Process.sleep(3000)
    IO.puts("\n Consenso según confirmado ... \n")

     # Verificar el estado de cada nodo
    IO.puts("\n Verificando estado final de los nodos...\n")
    Enum.each(procesos, fn pid -> send(pid, {:estado, nil}) end)

    procesos # Devolver los procesos para interaccion manual
  end


  # Crea `n` nodos, incluyendo `f` procesos bizantinos.
  defp crea_nodos(n, f) do
    # Crear `f` procesos bizantinos y `n - f` procesos honestos
    bizantinos = for _ <- 1..f, do: spawn(NodoBizantino, :inicia, [])
    honestos = for _ <- 1..(n - f), do: spawn(NodoHonesto, :inicia, [])
    honestos ++ bizantinos
  end

  # Asigna vecinos a los nodos de la red. Se asegura de que el coeficiente de agrupamiento sea mayor a 0.4.
  defp asigna_vecinos(procesos) do
    n = length(procesos)
    k = max(2, div(n, 4))  # Ajuste para definir la cantidad de vecinos

    # Paso 1: Crear conexiones iniciales (nodos en anillo con k vecinos)
    vecinos_iniciales = for i <- 0..(n - 1) do
      Enum.flat_map(1..div(k, 2), fn offset ->
        [
          Enum.at(procesos, rem(i + offset, n)),       # Acceso seguro a elementos usando Enum.at/2
          Enum.at(procesos, rem(i - offset + n, n))    # Acceso seguro a elementos usando Enum.at/2
        ]
      end)
    end

    # Hacer las conexiones bidireccionales
    vecinos_bidireccionales = Enum.reduce(0..(n - 1), vecinos_iniciales, fn i, acc ->
      Enum.reduce(Enum.at(acc, i), acc, fn vecino, acc_inner ->
        vecino_idx = Enum.find_index(procesos, fn p -> p == vecino end)

        # Agregar bidireccionalidad
        vecinos_actualizados =
          Enum.uniq(Enum.at(acc_inner, vecino_idx) ++ [Enum.at(procesos, i)])

        List.replace_at(acc_inner, vecino_idx, vecinos_actualizados)
      end)
    end)

    # Paso 2: Aplicar probabilidad de reenlace aleatorio
    probabilidad_reenlace = 0.1
    vecinos_random = Enum.map(0..(n - 1), fn i ->
      Enum.map(Enum.at(vecinos_bidireccionales, i), fn vecino ->
        if :rand.uniform() < probabilidad_reenlace do
          Enum.random(procesos -- [Enum.at(procesos, i) | Enum.at(vecinos_bidireccionales, i)])
        else
          vecino
        end
      end)
    end)

    # Hacer los vecinos bidireccionales tras reenlace
    vecinos_finales = Enum.reduce(0..(n - 1), vecinos_random, fn i, acc ->
      Enum.reduce(Enum.at(acc, i), acc, fn vecino, acc_inner ->
        vecino_idx = Enum.find_index(procesos, fn p -> p == vecino end)

        vecinos_actualizados =
          Enum.uniq(Enum.at(acc_inner, vecino_idx) ++ [Enum.at(procesos, i)])

        List.replace_at(acc_inner, vecino_idx, vecinos_actualizados)
      end)
    end)

    # Paso 3: Verificar coeficiente de agrupamiento
    if clustering_coefficient(vecinos_finales, procesos) < 0.4 do
      asigna_vecinos(procesos)  # Reintentar si no cumple
    else
      # Asignar los vecinos a los procesos
      Enum.each(0..(n - 1), fn i ->
        send(Enum.at(procesos, i), {:vecinos, Enum.at(vecinos_finales, i)})
      end)
    end
  end

  # Función para calcular el coeficiente de agrupamiento
  defp clustering_coefficient(vecinos, procesos) do
    n = length(vecinos)

    clustering_sum =
      Enum.reduce(0..(n - 1), 0, fn i, acc ->
        nodo_vecinos = Enum.at(vecinos, i)
        conexiones =
          for v1 <- nodo_vecinos, v2 <- nodo_vecinos, v1 != v2, do: {v1, v2}

        conexiones_validas =
          Enum.count(conexiones, fn {v1, v2} ->
            v2 in Enum.at(vecinos, Enum.find_index(procesos, fn p -> p == v1 end))
          end)

        acc + conexiones_validas / max(1, (length(nodo_vecinos) * (length(nodo_vecinos) - 1)))
      end)

    clustering_sum / n
  end
end

defmodule NodoHonesto do
  @moduledoc """
  Módulo de nodo honesto que simula un proceso no malicioso en la red.
  """

  @doc """
  Inicia un nodo honesto con el estado inicial especificado.
  """
  def inicia() do
    estado_inicial = %{
      :vecinos => [],
      :blockchain => Blockchain.new(),  # Crear una nueva blockchain
      :bizantino => false,
      :mensajes => %{:prepare => [], :commit => []}
    }
    Grafica.inicia(estado_inicial)
  end
end

defmodule NodoBizantino do
  @moduledoc """
  Módulo de nodo bizantino que simula un proceso malicioso en la red.
  """

  @doc """
  Inicia un nodo bizantino con el estado inicial especificado.
  """
  def inicia() do
    estado_inicial = %{
      :vecinos => [],
      :blockchain => Blockchain.new(),  # Crear blockchain, pero con posibilidad de modificarla
      :bizantino => true,
      :mensajes => %{:prepare => [], :commit => []}
    }
    Grafica.inicia(estado_inicial)
  end
end
