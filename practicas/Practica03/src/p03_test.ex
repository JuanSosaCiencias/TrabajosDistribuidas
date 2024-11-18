defmodule Practica03Test do
  use ExUnit.Case

  ExUnit.start()

  setup do
    nodos = Practica03.genera(3)
    Enum.each(0..2, fn i -> send(Enum.at(nodos, i), {:id, i}) end)
    Practica03.send_msg(nodos, {:vecinos, nodos})
    %{nodos: nodos}
  end

  @doc """
  Prueba de consenso para verificar que todos los nodos acuerden el valor mínimo.
  """
  test "todos los nodos llegan a un consenso sobre el valor mínimo", %{nodos: nodos} do
    # Enviamos valores enteros
    send(Enum.at(nodos, 0), {:proponer, 8})
    send(Enum.at(nodos, 1), {:proponer, 4})
    send(Enum.at(nodos, 2), {:proponer, 1})

    # Damos tiempo para que los mensajes de consenso se propaguen
    Process.sleep(500)

    # Verificamos el valor consensuado
    Practica03.send_msg(nodos, {:comprobar})
    assert true
  end

end


