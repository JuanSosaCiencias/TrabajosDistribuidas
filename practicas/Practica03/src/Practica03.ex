# --------Practica 02--------
defmodule Grafica do
  @moduledoc """
  Módulo que representa gráficas con un sistema de mensajes entre procesadores.
  Selecciona al nodo con menor valor de ID como líder.
  """


  def inicia(id, estado_inicial \\ %{:f => 5, :ronda => 0}) do
    estado_inicial = Map.put(estado_inicial, :id, id)
    recibe_mensaje(estado_inicial)
  end

  def inicia() do
    inicia(:default_id, %{:f => 5, :ronda => 0})
  end


  @doc """
  Recibe mensajes y los procesa, utiliza la funcion auxiliar `procesa_mensaje/2`.

  ## Parámetros
  - `estado` - Estado actual del proceso.

  ## Ejemplo
  ```elixir
  Grafica.recibe_mensaje(%{:visitado => false, :id => -1, :lider => nil, :vecinos => []})
  ```
  """
  def recibe_mensaje(estado) do
    receive do
      mensaje ->
        case procesa_mensaje(mensaje, estado) do
          {:ok, nuevo_estado} ->
            recibe_mensaje(nuevo_estado)

          {:consenso, nuevo_estado} ->
            %{:id => id} = nuevo_estado
              preferencias_sin_nil =
                nuevo_estado.preferencias
                |> Map.values()
                |> Enum.filter(&(!is_nil(&1)))

              y =
                if preferencias_sin_nil == [] do
                  nil
                else
                  Enum.max(preferencias_sin_nil)
                end
            # IO.inspect(nuevo_estado)
            IO.puts("Proceso finalizado para el Nodo #{id} #{inspect(self())} con valor consensuado: #{y}")
            {:finish, nuevo_estado}
        end
    end
  end


  def procesa_mensaje({:id, id}, estado) do
    IO.puts("Proceso con PID #{inspect(self())}: Recibí mi ID #{id}")
    estado = Map.put(estado, :id, id)
    {:ok, estado}
  end

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

  def procesa_mensaje({:mensaje, n_id}, estado) do
    IO.puts("Proceso con PID #{inspect(self())}: Recibí mensaje de mi vecino con ID #{n_id}")
    %{:id => id, :lider => lider_actual} = estado

    if n_id < (lider_actual || id) do
      IO.puts("Proceso con ID #{id}: Actualizando líder a #{n_id}")
      estado = Map.put(estado, :lider, n_id)
      propaga_lider(n_id, estado[:vecinos], id)
      {:ok, estado}
    else
      # Si el ID recibido es mayor o igual, no hace nada
      {:ok, estado}
    end
  end

  def procesa_mensaje({:inicia}, estado) do # Cuando un nodo recibe la señal de inicio, propaga su propio ID a sus vecinos y a sí mismo.
    IO.puts("Proceso con PID #{inspect(self())}: Iniciando y propagando mi ID")
    %{:id => id, :vecinos => vecinos, :lider => lider} = estado

    # Si no hay líder asignado aún, asigna el propio ID como líder
    lider = if lider == nil, do: id, else: lider
    estado = Map.put(estado, :lider, lider)

    # Propaga el líder que inicialmente será su propio ID a los vecinos y a sí mismo
    propaga_lider(lider, vecinos, id)
    {:ok, estado}
  end

  def procesa_mensaje({:proponer, valor}, estado) do
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
  Procesa diferentes tipos de mensajes y actualiza el estado del proceso.

  ## Tipos de mensajes:

  - `{:id, id}`: Recibe un ID y lo asigna al proceso.

    ## Ejemplo
    ```elixir
    Grafica.procesa_mensaje({:id, 20}, %{:visitado => false, :id => -1, :lider => nil, :vecinos => []})
    ```

  - `{:vecinos, vecinos}`: Recibe una lista de vecinos y la asigna al proceso.

    ## Ejemplo
    ```elixir
    Grafica.procesa_mensaje({:vecinos, [x, w]}, %{:visitado => false, :id => -1, :lider => nil, :vecinos => []})
    ```

  - `{:mensaje, n_id}`: Recibe el ID de un vecino y actualiza el líder si es necesario.

    ## Ejemplo
    ```elixir
    Grafica.procesa_mensaje({:mensaje, 20}, %{:visitado => false, :id => -1, :lider => nil, :vecinos => []})
    ```

  - `{:inicia}`: Señal de inicio, propaga su propio ID como el líder a sus vecinos.

    ## Ejemplo
    ```elixir
    Grafica.procesa_mensaje({:inicia}, %{:visitado => false, :id => -1, :lider => nil, :vecinos => []})
    ```

  - `{:ya}`: Señal de verificación, imprime el líder actual del proceso.

    ## Ejemplo
    ```elixir
    Grafica.procesa_mensaje({:ya}, %{:visitado => false, :id => -1, :lider => nil, :vecinos => []})
    ```
  """
  def procesa_mensaje({:ya}, estado) do
    %{:id => id, :lider => lider} = estado
    if lider == id do
      IO.puts("Proceso con ID #{id}: Soy el líder")
    else
      IO.puts("Proceso con ID #{id}: El líder es #{lider}")
    end
    {:ok, estado}
  end

  @doc """
  Propaga el líder a los vecinos y a sí mismo.

  ## Parámetros
  - `nuevo_lider` - ID del nuevo líder.
  - `vecinos` - Lista de vecinos.
  - `id` - ID del proceso actual.

  ## Ejemplo
  ```elixir
  Grafica.propaga_lider(20, [x, w], 20)
  ```
  """
  def propaga_lider(nuevo_lider, vecinos, id) do
    IO.puts("Proceso con ID #{id}: Propagando el líder #{nuevo_lider} a todos mis vecinos y a mí mismo")

    # # Contar cuántos mensajes se enviarán
    # cantidad_mensajes = length(vecinos) + 1  # Se incluye al proceso mismo

    # # Incrementa el contador por el número de mensajes enviados
    # Enum.each(1..cantidad_mensajes, fn _ -> ContadorMensajes.incrementar() end)

    # Enviar el mensaje a todos los vecinos y al propio proceso
    Enum.each(vecinos ++ [self()], fn vecino -> send(vecino, {:mensaje, nuevo_lider}) end)
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

defmodule ContadorMensajes do
  @moduledoc """
  Módulo que cuenta el número de mensajes enviados.
  Codigo 100% hecho por Copilot.
  """

  @doc """
  Inicia el contador de mensajes.

  ## Ejemplo
  ```elixir
  ContadorMensajes.iniciar()
  ```
  """
  def iniciar() do
    Agent.start_link(fn -> 0 end, name: __MODULE__)
  end

  @doc """
  Incrementa el contador de mensajes en 1.

  ## Ejemplo
  ```elixir
  ContadorMensajes.incrementar()
  ```
  """
  def incrementar() do
    Agent.update(__MODULE__, &(&1 + 1))
  end

  @doc """
  Obtiene el valor actual del contador de mensajes.

  ## Ejemplo
  ```elixir
  ContadorMensajes.obtener()
  ```
  """
  def obtener() do
    Agent.get(__MODULE__, & &1)
  end
end

# --------end Practica 02--------




#------------Practica 03------------------
defmodule Practica03 do
  @doc """
  Genera `n` procesos de un modulo en particular.

  ## Parámetros
  - `n` - Número de procesos a generar.
  - `modulo` - Módulo en particular (puede ser grafica)
  - `funcion` - Función a ejecutar.
  - [] - acumulador

  ## Ejemplo
  ```elixir
  Practica03.spawn_in_list(4, Grafica, :inicia, [])
  ```
  """
  def spawn_in_list(n, modulo, funcion, acc) when is_integer(n) do
		case n do
			0 -> acc
			n -> spawn_in_list(n-1, modulo, funcion, acc++[spawn(modulo, funcion, [])])
		end
	end

  @doc """
  Genera `n` procesos de la gráfica.

  ## Parámetros
  - `n` - Número de procesos a generar.

  ## Ejemplo
  ```elixir
  lista = Practica03.genera(4)
  ```
  """
	def genera(n) when is_integer(n) do
		spawn_in_list(n, Grafica, :inicia, [])
	end

  @doc """
  Envia un mensaje a una lista de procesos.

  ## Parámetros
  - `lista` - Lista de procesos.
  - `mensaje` - Mensaje a enviar.

  ## Ejemplo
  ```elixir
  Practica03.send_msg(lista, {:inicia})
  ```
  """
	def send_msg(lista, mensaje) do
    Enum.each(lista, fn proceso -> send(proceso, mensaje) end)
  end
end

#--------------end Practica 03------------------------
# nodos = 1..5 |> Enum.map(fn id -> spawn_link(Grafica, :inicia, [id]) end)
# Enum.each(nodos, fn nodo -> send(nodo, {:vecinos, nodos}) end)
# first_node = Enum.random(nodos)
# second_node = Enum.random(nodos)
# send(first_node, {:proponer, 1})
# send(second_node, {:proponer, 1})
