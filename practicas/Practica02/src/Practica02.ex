defmodule Grafica do
  @moduledoc """
  Módulo que representa gráficas con un sistema de mensajes entre procesadores.
  Selecciona al nodo con menor valor de ID como líder.
  """

  @doc """
  Inicia el proceso de la gráfica.

  ## Parámetros
  - `estado_inicial` - Estado inicial del proceso, sin visitar sin ID, sin líder y sin vecinos.

  ## Ejemplo
  ```elixir
  Grafica.inicia(%{:visitado => false, :id => -1, :lider => nil, :vecinos => []})
  ```
  """
  def inicia(estado_inicial \\ %{:visitado => false, :id => -1, :lider => nil, :vecinos => []}) do
    recibe_mensaje(estado_inicial)
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
        {:ok, nuevo_estado} = procesa_mensaje(mensaje, estado)
      recibe_mensaje(nuevo_estado)
    end
  end

  def procesa_mensaje({:id, id}, estado) do
    IO.puts("Proceso con PID #{inspect(self())}: Recibí mi ID #{id}")
    estado = Map.put(estado, :id, id)
    {:ok, estado}
  end

  def procesa_mensaje({:vecinos, vecinos}, estado) do
    IO.puts("Proceso con PID #{inspect(self())}: Recibí mis vecinos: #{inspect(vecinos)}")
    estado = Map.put(estado, :vecinos, vecinos)
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
  defp propaga_lider(nuevo_lider, vecinos, id) do
    IO.puts("Proceso con ID #{id}: Propagando el líder #{nuevo_lider} a todos mis vecinos y a mí mismo")

    # Contar cuántos mensajes se enviarán
    cantidad_mensajes = length(vecinos) + 1  # Se incluye al proceso mismo

    # Incrementa el contador por el número de mensajes enviados
    Enum.each(1..cantidad_mensajes, fn _ -> ContadorMensajes.incrementar() end)

    # Enviar el mensaje a todos los vecinos y al propio proceso
    Enum.each(vecinos ++ [self()], fn vecino -> send(vecino, {:mensaje, nuevo_lider}) end)
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


# Se crean los procesos y se guardan sus PID.
t = spawn(Grafica, :inicia, [])
u = spawn(Grafica, :inicia, [])
v = spawn(Grafica, :inicia, [])
w = spawn(Grafica, :inicia, [])
x = spawn(Grafica, :inicia, [])
y = spawn(Grafica, :inicia, [])
z = spawn(Grafica, :inicia, [])

s = spawn(Grafica, :inicia, [])
q = spawn(Grafica, :inicia, [])
r = spawn(Grafica, :inicia, [])

# A cada proceso le enviamos su identificador
send(t, {:id, 20})
send(u, {:id, 21})
send(v, {:id, 22})
send(w, {:id, 23})
send(x, {:id, 24})
send(y, {:id, 25})
send(z, {:id, 26})

send(s, {:id, 19})
send(q, {:id, 17})
send(r, {:id, 18})

# A cada proceso le enviamos sus vecinos
send(t, {:vecinos, [x, w]})
send(u, {:vecinos, [y]})
send(v, {:vecinos, [x]})
send(w, {:vecinos, [t, x]})
send(x, {:vecinos, [t, v, w, y]})
send(y, {:vecinos, [x, z, u]})
send(z, {:vecinos, [y]})

send(q, {:vecinos, [s]})
send(r, {:vecinos, [s]})
send(s, {:vecinos, [q,r]})

# Iniciamos la propagación de forma asíncrona
IO.puts("----------------")
IO.puts("Iniciando propagación")
IO.puts("----------------")

# Iniciar el contador de mensajes
ContadorMensajes.iniciar()

# Propagación asincrónica: Cada proceso comenzará en orden.
send(t, {:inicia})
send(u, {:inicia})
send(v, {:inicia})
send(w, {:inicia})
send(x, {:inicia})
send(y, {:inicia})
send(z, {:inicia})

send(s, {:inicia})
send(q, {:inicia})
send(r, {:inicia})

# Verificación del líder en cada nodo.
Process.sleep(1000)
IO.puts("----------------")
IO.puts("Verificando elección de líder")
IO.puts("----------------")

send(t, {:ya})
send(u, {:ya})
send(v, {:ya})
send(w, {:ya})
send(x, {:ya})
send(y, {:ya})
send(z, {:ya})

send(s, {:ya})
send(q, {:ya})
send(r, {:ya})

# Obtener el total de mensajes enviados (Extra) esta entre 60 y 80 mensajes. O(|E|*|V|)
Process.sleep(1000)
IO.puts("----------------")
IO.puts("Total de mensajes enviados: #{ContadorMensajes.obtener()}")
IO.puts("----------------")
