defmodule Grafica do
  @moduledoc """
  Módulo que representa un grafo distribuido, donde cada proceso actúa como un nodo que intercambia mensajes.
  Los procesos reciben y procesan mensajes para actualizar su estado, propagar información entre sus vecinos y
  detectar si han sido visitados en el contexto de un algoritmo de conexión de grafos.
  Se incluye el Algoritmo 16, sección 5.2.5 del libro Hagit Attiya y Jennifer Welch, Distributed Computing
  para hacer consenso basado en rondas
  """

  @doc """
  Inicia el nodo con un estado inicial. El nodo está marcado como no procesado y no es la raíz.
  Llama a la función `recibe_mensaje/1` para comenzar a recibir mensajes.
  ## Parámetros:
  - `id`: El identificador del nodo.
  - `estado_inicial`: El estado inicial del nodo, con `:f` y `:ronda` como claves principales. Valor por defecto: `%{:f => 5, :ronda => 0}`.
  """
  def inicia(id, estado_inicial \\ %{:f => 5, :ronda => 0}) do
    estado_inicial = Map.put(estado_inicial, :id, id)
    recibe_mensaje(estado_inicial)
  end

  @doc """
  Función que recibe mensajes enviados al proceso actual. Dependiendo del tipo de mensaje,
  se ejecuta una acción específica para modificar el estado del nodo.

  El proceso espera de manera indefinida hasta recibir un mensaje y lo procesa, llamando a la función `procesa_mensaje/2`.
  Después de procesar el mensaje, vuelve a esperar un nuevo mensaje en un ciclo recursivo.
  ## Parámetros:
  - `estado`: El estado actual del nodo.
  """
  def recibe_mensaje(estado) do
    receive do
      mensaje ->
        case procesa_mensaje(mensaje, estado) do
          {:ok, nuevo_estado} ->
            recibe_mensaje(nuevo_estado)

          {:consenso, nuevo_estado} ->
            %{:id => id} = nuevo_estado
            y = Map.get(estado.preferencias, self())
            IO.puts("Proceso finalizado para el Nodo #{id} #{inspect(self())} con valor consensuado: #{y}")
            {:finish, nuevo_estado}
        end
    end
  end

  @doc """
  Procesa diferentes tipos de mensajes:

  - `{:vecinos, vecinos}`: Inicializa las preferencias del nodo para todos sus vecinos.
  - `{:proponer_valor, valor}`: Propuesta de valor por parte de un nodo.
  - `{:king_maj, valor}`: Mensaje del nodo rey con el valor mayoritario.
  - `{:consenso, valor, pid}`: Mensaje de consenso recibido desde otro nodo.

  ## Parámetros:
  - `mensaje`: Un mensaje en formato tupla que indica la acción a tomar.
  - `estado`: El estado actual del nodo.
  """
  def procesa_mensaje({:vecinos, vecinos}, estado) do
    preferencias = %{self() => nil}
    vecinos = vecinos -- [self()]

    # Usamos Enum.reduce para ir actualizando el map
    preferencias = Enum.reduce(vecinos, preferencias, fn vecino, acc ->
      Map.put(acc, vecino, nil)
    end)

    estado = Map.put(estado, :vecinos, vecinos)
    estado = Map.put(estado, :preferencias, preferencias)
    {:ok, estado}
  end

  def procesa_mensaje({:proponer_valor, valor}, estado) do
    %{:id => id, :vecinos => vecinos, :preferencias => preferencias} = estado
    IO.puts("Soy el nodo #{id} #{inspect(self())} y propongo un valor")
    preferencias = Map.put(preferencias, self(), valor)
    Map.put(estado, :preferencias, preferencias)
    Enum.each(vecinos, fn vecino ->
      send vecino, {:consenso, valor, self()}
    end)
    {:ok, estado}
  end

  def procesa_mensaje({:king_maj, valor}, estado) do
    %{:maj => maj, :mult => mult, :vecinos => vecinos, :f => f} = estado
    n = length(vecinos)
    # Si multiplicidad de maj es mayor que n/2 + f, adoptamos maj como valor preferido
    if mult > div(n, 2) + f do
      preferencias = Map.put(estado.preferencias, self(), maj)
      ^estado = Map.put(estado, :preferencias, preferencias)
    else
      preferencias = Map.put(estado.preferencias, self(), valor)
      ^estado = Map.put(estado, :preferencias, preferencias)
    end
    {:ok, estado}
  end

  def procesa_mensaje({:consenso, valor, pid}, estado) do
    %{
      :id => id,
      :ronda => k,
      :preferencias => preferencias
    } = estado
    IO.puts("Nodo #{id} recibe valor #{valor} de #{inspect(pid)} en la ronda #{k}")

    nuevas_preferencias = Map.put(preferencias, pid, valor)
    estado = Map.put(estado, :preferencias, nuevas_preferencias)
    # Calculamos el valor mayoritario (maj) y su multiplicidad (mult)
    valores = Map.values(nuevas_preferencias)
    maj = mayoritario(valores)
    mult = Enum.count(valores, fn v -> v == maj end)


    estado = Map.put(estado, :maj, maj)
    estado = Map.put(estado, :mult, mult)
    siguiente_ronda(estado)
  end

  @doc """
  Avanza el algoritmo a la siguiente ronda (2k). Si la ronda actual es la del nodo rey,
  este envía el valor mayoritario (`maj`) a todos sus vecinos. Si se alcanza la última ronda permitida, el algoritmo termina.

  ## Parámetros:
  - `estado`: El estado actual del nodo.
  """
  def siguiente_ronda(estado) do
    %{:id => id, :ronda => k, :maj => maj, :vecinos => vecinos, :f => f} = estado

    # Nodo rey envía maj a todos
    if k == id do
      IO.puts("Soy el rey en la ronda #{k}, enviando mi mayoritario a todos")
      Enum.each(vecinos, fn vecino ->
        send vecino, {:king_maj, maj}
      end)
    end

    if k == f+1 do
      {:consenso, estado} #TERMINAMOS!
    else
      estado = Map.put(estado, :ronda, k + 1)
      Enum.each(vecinos, fn vecino -> send vecino, {:consenso, maj, self()} end)
      {:ok, estado}
    end
  end

  @doc """
  Calcula el valor mayoritario de una lista de valores, es decir, el valor que ocurre con mayor frecuencia.

  ## Parámetros:
  - `valores`: Lista de valores de las preferencias de los nodos.

  ## Retorna:
  - El valor que tiene la mayor frecuencia en la lista.
  """
  def mayoritario(valores) do
    valores
    |> Enum.frequencies()
    |> Enum.max_by(fn {_valor, frecuencia} -> frecuencia end)
    |> elem(0)
  end
end

nodos = 1..5 |> Enum.map(fn id -> spawn_link(Grafica, :inicia, [id]) end)
Enum.each(nodos, fn nodo -> send(nodo, {:vecinos, nodos}) end)

first_node = Enum.random(nodos)
second_node = Enum.random(nodos)
send(first_node, {:proponer_valor, 1})
send(second_node, {:proponer_valor, 1})
