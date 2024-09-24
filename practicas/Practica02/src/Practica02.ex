defmodule Grafica do
  @moduledoc """
  Módulo que representa gráficas con un sistema de mensajes entre procesadores.
  Selecciona al nodo con menor valor de ID como líder. 
  """
  
  def inicia(estado_inicial \\ %{:visitado => false, :id => -1, :lider => nil, :vecinos => []}) do
    recibe_mensaje(estado_inicial)
  end

  def recibe_mensaje(estado) do
    receive do
      mensaje -> 
        {:ok, nuevo_estado} = procesa_mensaje(mensaje, estado)      
      recibe_mensaje(nuevo_estado)
    end       
  end  

  # Recibe el ID del proceso y lo almacena en el estado.
  def procesa_mensaje({:id, id}, estado) do
    IO.puts("Proceso con PID #{inspect(self())}: Recibí mi ID #{id}")
    estado = Map.put(estado, :id, id)
    {:ok, estado}
  end  

  # Recibe la lista de vecinos y lo almacena en el estado.
  def procesa_mensaje({:vecinos, vecinos}, estado) do
    IO.puts("Proceso con PID #{inspect(self())}: Recibí mis vecinos: #{inspect(vecinos)}")
    estado = Map.put(estado, :vecinos, vecinos)
    {:ok, estado}
  end  

  # Procesa el mensaje de ID recibido de otro nodo.
  def procesa_mensaje({:mensaje, n_id}, estado) do
    IO.puts("Proceso con PID #{inspect(self())}: Recibí mensaje de mi vecino con ID #{n_id}")
    %{:id => id, :lider => lider_actual} = estado
    
    # Si el ID recibido es menor, actualiza el líder y propaga
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

  # Cuando un nodo recibe la señal de inicio, propaga su propio ID a sus vecinos y a sí mismo.
  def procesa_mensaje({:inicia}, estado) do
    IO.puts("Proceso con PID #{inspect(self())}: Iniciando y propagando mi ID")
    %{:id => id, :vecinos => vecinos, :lider => lider} = estado

    # Si no hay líder asignado aún, asigna el propio ID como líder
    lider = if lider == nil, do: id, else: lider
    estado = Map.put(estado, :lider, lider)

    # Propaga el líder que inicialmente será su propio ID a los vecinos y a sí mismo
    propaga_lider(lider, vecinos, id)
    {:ok, estado}
  end    

  # Verifica el líder actual del nodo y lo imprime.
  def procesa_mensaje({:ya}, estado) do
    %{:id => id, :lider => lider} = estado
    if lider == id do
      IO.puts("Proceso con ID #{id}: Soy el líder")
    else 
      IO.puts("Proceso con ID #{id}: El líder es #{lider}")
    end
    {:ok, estado}
  end    

  # Propaga el líder a los vecinos si es el menor ID, y también a sí mismo.
  defp propaga_lider(nuevo_lider, vecinos, id) do
    IO.puts("Proceso con ID #{id}: Propagando el líder #{nuevo_lider} a todos mis vecinos y a mí mismo")
    
    # Incluye al propio proceso en la lista de vecinos
    Enum.each(vecinos ++ [self()], fn vecino -> send(vecino, {:mensaje, nuevo_lider}) end)
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

# A cada proceso le enviamos su identificador
send(t, {:id, 20})
send(u, {:id, 21})
send(v, {:id, 22})
send(w, {:id, 23})
send(x, {:id, 24})
send(y, {:id, 25})
send(z, {:id, 26})

# A cada proceso le enviamos sus vecinos
send(t, {:vecinos, [x, w]})  
send(u, {:vecinos, [y]})    
send(v, {:vecinos, [x]})    
send(w, {:vecinos, [t, x]})
send(x, {:vecinos, [t, v, w, y]})
send(y, {:vecinos, [x, z, u]})
send(z, {:vecinos, [y]})

# Iniciamos la propagación de forma asíncrona

IO.puts("----------------")  
IO.puts("Iniciando propagación")  
IO.puts("----------------")  

# Propagación asincrónica: Cada proceso comenzará en orden.
send(t, {:inicia})
Process.sleep(1000)  
send(u, {:inicia})
Process.sleep(1000)
send(v, {:inicia})
Process.sleep(1000)
send(w, {:inicia})
Process.sleep(1000)
send(x, {:inicia})
Process.sleep(1000)
send(y, {:inicia})
Process.sleep(1000)
send(z, {:inicia})

# Verificación del líder en cada nodo.
Process.sleep(2000)
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
