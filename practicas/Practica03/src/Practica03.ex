# --------Practica 02--------
defmodule Grafica do

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

  def procesa_mensaje({:ya}, estado) do
    %{:id => id, :lider => lider} = estado
    if lider == id do
      IO.puts("Proceso con ID #{id}: Soy el líder")
    else
      IO.puts("Proceso con ID #{id}: El líder es #{lider}")
    end
    {:ok, estado}
  end

  defp propaga_lider(nuevo_lider, vecinos, id) do
    IO.puts("Proceso con ID #{id}: Propagando el líder #{nuevo_lider} a todos mis vecinos y a mí mismo")

    # Enviar el mensaje a todos los vecinos y al propio proceso
    Enum.each(vecinos ++ [self()], fn vecino -> send(vecino, {:mensaje, nuevo_lider}) end)
  end
end

# --------end Practica 02--------




#------------Practica 03------------------
defmodule Practica03 do
def spawn_in_list(n, modulo, funcion, []) when is_integer(n) do
		case n do
			0 -> []
			n -> [spawn(modulo, funcion, [])] ++ spawn_in_list(n-1, modulo, funcion, [])
		end
	end

	def spawn_in_list(n, modulo, funcion, args) when is_integer(n) do
		case n do
			0 -> []
			n -> [spawn(modulo, funcion, args)] ++ spawn_in_list(n-1, modulo, funcion, args)
		end
	end

	def genera(n) when is_integer(n) do
		spawn_in_list(n, Grafica, :inicia, [])
	end

	def send_msg(lista, mensaje) do
		 Enum.each(lista, fn proceso -> send(proceso, mensaje) end)
	end
end

#--------------end Practica 03------------------------
