# -------- Módulo Main --------
defmodule Main do
  @moduledoc """
  Módulo principal que maneja la creación de la red de nodos, incluyendo procesos honestos y bizantinos,
  y simula la blockchain distribuida.
  """

  @doc """
  Función principal que inicializa la red de `n` nodos y `f` procesos bizantinos.
  """
  def run(n, f) do
    IO.puts("Iniciando la red con #{n} nodos, incluyendo #{f} procesos bizantinos...")

    procesos = crea_nodos(n, f)  # Corrige esta línea si corresponde
    vecinos = asigna_vecinos(procesos)

    # Uso de otras funciones
    # inicializa_nodos(procesos)
    # simular_transacciones(procesos)

    Enum.each(procesos, fn proceso ->
      IO.inspect(proceso)
    end)

    vecinos
  end



  defp crea_nodos(n, f) do
    # Crear `f` procesos bizantinos y `n - f` procesos honestos
    bizantinos = for _ <- 1..f, do: spawn(NodoBizantino, :inicia, [])
    honestos = for _ <- 1..(n - f), do: spawn(NodoHonesto, :inicia, [])

    bizantinos ++ honestos
  end

  # """
  # Asigna vecinos a los nodos siguiendo el modelo de Watts y Strogatz.
  # Garantiza un coeficiente de agrupamiento > 0.4.
  # """
  defp asigna_vecinos(procesos) do
    n = length(procesos)
    k = max(2, div(n, 4))  # Ajuste para definir la cantidad de vecinos

    # Paso 1: Conexiones iniciales (nodos en anillo con k vecinos)
    vecinos = for i <- 0..(n - 1) do
      Enum.flat_map(1..div(k, 2), fn offset ->
        [
          Enum.at(procesos, rem(i + offset, n)),       # Acceso seguro a elementos usando Enum.at/2
          Enum.at(procesos, rem(i - offset + n, n))    # Acceso seguro a elementos usando Enum.at/2
        ]
      end)
    end

    # Paso 2: Reenlaces aleatorios
    probabilidad_reenlace = 0.1  # Probabilidad de reenlace para aleatoriedad
    vecinos_random = Enum.map(0..(n - 1), fn i ->
      Enum.map(vecinos |> Enum.at(i), fn vecino ->
        if :rand.uniform() < probabilidad_reenlace do
          Enum.random(procesos -- [Enum.at(procesos, i) | vecinos |> Enum.at(i)])
        else
          vecino
        end
      end)
    end)

    # Asignar los vecinos a los procesos
    Enum.each(0..(n - 1), fn i ->
      send(Enum.at(procesos, i), {:vecinos, Enum.at(vecinos_random, i)})
    end)
  end

  # defp inicializa_nodos(red) do
  #   Enum.each(red, fn {proceso, _} ->
  #     send(proceso, {:inicia})
  #   end)
  # end

  # defp simular_transacciones(red) do
  #   # Simulación de transacciones y consenso en la red
  #   # Este es un lugar donde se puede implementar la lógica de generación de bloques y votaciones
  #   Enum.each(red, fn {proceso, _} ->
  #     send(proceso, {:proponer, "Transacción de prueba"})
  #   end)

  #   # Simulación de una blockchain
  #   [
  #     %{id: 1, data: "Bloque inicial", hash: "0000", prev_hash: "0000"},
  #     %{id: 2, data: "Transacción 1", hash: "abcd", prev_hash: "0000"}
  #   ]
  # end
end

# --------end--------

# -------- Módulo NodoHonesto --------
defmodule NodoHonesto do
  def inicia() do
    Grafica.inicia()
  end
end

# -------- Módulo NodoBizantino --------
defmodule NodoBizantino do
  def inicia() do
    recibe_mensaje()
  end

  defp recibe_mensaje() do
    receive do
      {:proponer, _valor} ->
        # Generar bloque basura y enviarlo a los vecinos
        IO.puts("Nodo bizantino generando bloque malicioso")
        # Lógica para propagar bloque malicioso
    end
  end
end

# --------end--------
