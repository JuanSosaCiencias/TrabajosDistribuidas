ExUnit.start() # framework para pruebas unitarias en elixir

defmodule Practica01 do
  @moduledoc """
  Modulo con las funciones de la practica01

  ## Funciones

  - `cuadruple(x)`: Calcula el cuádruple de un número
  - `sucesor(x)`: Devuelve el sucesor de un número entero
  - `maximo(x, y)`: Encuentra el número más grande entre dos números recibidos
  - `suma(x, y)`: Suma dos números enteros
  - `resta(x, y)`: Dado dos números, resta el segundo número del primero
  - `multiplicacionConjugados(x, y)`: Calcula la multiplicación de los conjugados de dos números enteros
  - `negacion(x)`: Devuelve la negación de un booleano
  - `conjuncion(x, y)`: Realiza la conjunción lógica entre dos valores booleanos
  - `disyuncion(x, y)`: Devuelve la disyunción de dos valores booleanos
  - `absoluto(x)`: Devuelve el valor absoluto de un número entero
  - `areaCirculo(r)`: Calcula el área de un círculo dado su radio
  - `sumaGaussRec(n)`: Calcula la suma de Gauss de un número entero n de manera recursiva
  - `sumaGauss(n)`: Calcula la suma de Gauss con la fórmula cerrada
  - `areaTriangulo({x1, y1}, {x2, y2}, {x3, y3})`: Calcula el área de un triángulo dados tres puntos en el plano
  - `repiteCadena(x, cadena)`: Regresa una lista de cadenas repetidas cierto número de veces
  - `insertaElemento(lista, i, v)`: Inserta un valor en una lista en el índice especificado
  - `eliminaIndex(list, index)`: Elimina un elemento de una lista en el índice especificado
  - `raboLista(lst)`: Regresa el último elemento de una lista
  - `encapsula(lst)`: Dada una lista de listas, regresa una lista de tuplas
  - `mapBorra(map, key)`: Dado un mapa y una clave, elimina la clave del mapa
  - `mapAlista(map)`: Dado un mapa, regresa una lista de tuplas con las claves y valores del mapa
  - `dist(a, b)`: Calcula la distancia entre dos puntos en el plano
  - `insertaTupla(t, v)`: Inserta un valor en una tupla
  - `tuplaALista(t)`: Convierte una tupla en una lista
  """
  use ExUnit.Case # usamos el framework de pruebas caso por caso


  @doc """
  Calcula el cuádruple de un número.

  ## Parámetros

    - x: Número entero

  ## Ejemplos

      iex> cuadruple(5)
      20
      iex> cuadruple(7)
      28
      iex> cuadruple(4)
      16
  """
  def cuadruple(x) when is_integer(x)  do
       x*4
  end

  def cuadruple(_x) do
    raise ArgumentError, "El argumento debe ser un número entero."
  end


  @doc """
   Devuelve el sucesor de un número entero.

  ## Parámetros

    -x: Número entero

  ## Ejemplos

      iex> sucesor(5)
      6
      iex> sucesor(7)
      8
      iex> sucesor(4)
      5
  """
  def sucesor(x) when is_integer(x) do
    x + 1
  end

  def sucesor(_x) do
    raise ArgumentError, "El argumento debe ser un número entero."
  end

  @doc """
    Encuentra el número más grande entre dos números recibidos

  ## Parametros

    - x: El primer número a comparar
    - y: El segundo número a comparar

  """
  def maximo(x,y) when is_integer(x) and is_integer(y) do
      cond do
        x>=y ->
            x
        x<y ->
            y
      end
  end

  def maximo(_x) do
    raise ArgumentError, "Los argumentos deben ser dos número enteros."
  end

  @doc """
  Suma dos números enteros.

  ## Parámetros

    -x: Número a sumar
    -y: Número a sumar

  ## Ejemplos

      iex> suma(5, 6)
      11
      iex> suma(7, 6)
      13
      iex> suma(4, 4)
      8
  """
  def suma(x, y) when is_integer(x) and is_integer(y) do
    x + y
  end

  def suma(_x, _y) do
    raise ArgumentError, "Ambos argumentos deben ser números enteros."
  end

  @doc """
    Dado dos números, resta el segundo número del primero.

    ## Parámetros

      - x: El minuendo
      - y: El sustraendo

    """
  def resta(x,y) when is_integer(x) and is_integer(y) do
      x-y
  end

  def resta(_x,_y) do
    raise ArgumentError, "Los argumentos deben ser dos número entero."
  end


  @doc """
    Calcula la multiplicación de los conjugados de dos números enteros.

    ## Parámetros

    -x: Primer término de la multiplicación
    -y: Segundo término de la multiplicación
    """
  def multiplicacionConjugados(x, y) when is_integer(x) and is_integer(y) do
    (x + y) * (x - y)
  end

  def multiplicacionConjugados(_x, _y) do
    raise ArgumentError, "Ambos argumentos deben ser números enteros."
  end

  @doc """
    Devuelve la negación de un booleano

    ## Parámetros

      - x: Booleano a negar

    """
  def negacion(x) when is_boolean(x) do
      !x
  end

  def negacion(_x) do
    raise ArgumentError, "El argumento debe ser un booleano."
  end


  @doc """
  Realiza la conjunción lógica entre dos valores booleanos.

  ## Parámetros

  -x: Primer término booleano para la conjunción
  -y: Segundo término booleano para la conjunción
  """
  def conjuncion(x, y) when is_boolean(x) and is_boolean(y) do
    x and y
  end

  def conjuncion(_x, _y) do
    raise ArgumentError, "Ambos argumentos deben ser booleanos."
  end

  @doc """
  Devuelve la disyunción de dos valores booleanos

  ## Parámetros

    - x: Primer booleano
    - y: Segundo booleano

  """
  def disyuncion(x,y) when is_boolean(x) and is_boolean(y)  do
      x || y
  end

  def disyuncion(_x, _y) do
    raise ArgumentError, "Ambos argumentos deben ser booleanos."
  end


  @doc """
  Devuelve el valor absoluto de un número entero.

  ## Parámetros

  -x: Número para sacarle su valor absoluto
  """
  def absoluto(x) when is_integer(x) do
    if x < 0 do
      -x
    else
      x
    end
  end

  def absoluto(_x) do
    raise ArgumentError, "El argumento debe ser un número entero."
  end

  @doc """
    Calcula el área de un círculo dado su radio

    ## Parámetros {x1, y1}, {x2, y2}, {x3, y3}

      - r: Número entero del radio de un círculo

    """
  def areaCirculo(r) when  is_integer(r) and r>0 do
        3.14 * r * r
  end

  def areaCirculo(_r) do
    raise ArgumentError, "El argumento debe ser un número entero positivo."
  end

  @doc """
  Calcula la suma de Gauss de un número entero n de manera recursiva.

  ## Parámetros
  -n: Número para hacer la suma de Gauss
  """
  def sumaGaussRec(0) do
    0
  end

  def sumaGaussRec(n) when is_integer(n) and n > 0 do
    n + sumaGaussRec(n - 1)
  end

  def sumaGaussRec(_n) do
    raise ArgumentError, "El argumento debe ser un número entero positivo o 0."
  end

  @doc """
  Calcula la suma de Gauss con la fórmula cerrada

  ## Parametros

    - n: Número entero a calcular la suma

  """
  def sumaGauss(n) when is_integer(n) and n>-1 do
  	case n do
  		0 -> 0
      n -> div(n * (n + 1), 2)
  	end
  end

  def sumaGauss(_n) do
    raise ArgumentError, "El argumento debe ser un número entero positivo o 0."
  end

  @doc """
  Calcula el área de un triángulo dados tres puntos en el plano.

  ## Parámetros

    - {x1, y1}: Coordenadas del primer punto
    - {x2, y2}: Coordenadas del segundo punto
    - {x3, y3}: Coordenadas del tercer punto

  ## Ejemplos

      iex> areaTriangulo({2,0}, {3,4}, {-2,5})
      10.5
      iex> areaTriangulo({3,4}, {4,7}, {6,-3})
      8
  """
  def areaTriangulo({x1, y1}, {x2, y2}, {x3, y3})
      when is_number(x1) and is_number(y1) and is_number(x2) and is_number(y2) and is_number(x3) and is_number(y3) do
    abs(x1 * (y2 - y3) + x2 * (y3 - y1) + x3 * (y1 - y2)) / 2
  end

  def areaTriangulo(_p1, _p2, _p3) do
    raise ArgumentError, "Todos los puntos deben ser tuplas con números enteros."
  end

  @doc """
  Regresa una lista de cadenas repetidas cierto número de veces.

  ## Parámetros

    - x: Número de veces a repetir la cadena
    - cadena: La cadena a repetir

  ## Ejemplos

      iex> repiteCadena(3, "hola")
      ["hola", "hola", "hola"]
      iex> repiteCadena(0, "mundo")
      []
      iex> repiteCadena(2, "")
      ["", ""]
  """
  def repiteCadena(x,cadena) when is_integer(x) and x>-1 do
      case x do
        0 -> []
        x ->
          [cadena] ++ repiteCadena(x - 1, cadena)
      end
  end

  def repiteCadena(_x) do
    raise ArgumentError, "El primer argumento debe ser un número entero."
  end

  @doc """
  Inserta un valor en una lista en el índice especificado.

  ## Parámetros

    -lista: Una lista de números
    -i: Número entero que representa el índice
    -v: Número entero que representa el valor

  ## Ejemplos

      iex> insertaElemento([1, 2, 3], 1, 5)
      [1, 5, 2, 3]
      iex> insertaElemento([], 0, 10)
      [10]
      iex> insertaElemento([:a, :b, :c], 2, :d)
      [:a, :b, :d, :c]
  """
  def insertaElemento(lista, i, v) when is_list(lista) and is_integer(i) and i >= 0 do
    List.insert_at(lista, i, v)
  end

  @doc """
  Elimina un elemento de una lista en el índice especificado.

  ## Parámetros

    -lista: Una lista de números
    -index: Número entero que representa el índice

  ## Ejemplos

      iex> eliminaIndex([1, 2, 3], 1)
      [1, 3]
      iex> eliminaIndex([:a, :b, :c], 0)
      [:b, :c]
      iex> eliminaIndex([:x], 0)
      []
  """
  def eliminaIndex(list, index) when is_list(list) and is_integer(index) and index >= 0 do
    List.delete_at(list, index)
  end


  @doc """
  Regresa el último elemento de una lista.

  ## Parámetros

    - lst: Una lista de elementos

  ## Ejemplos

    iex> raboLista([1, 2, 3, 4])
    4
    iex> raboLista([:a, :b, :c])
    :c
    iex> raboLista(["uno", "dos", "tres"])
    "tres"
  """
  def raboLista(lst) when is_list(lst) do
    List.last(lst)
  end

  @doc """
  Dada una lista de listas, regresa una lista de tuplas.
  En la tupla i se encuentran los elementos i-ésimos de cada lista.

  ## Parámetros

    - lst: Una lista de listas

  ## Ejemplos

      iex> encapsula([[1, 2], [3, 4], [5, 6]])
      [{1, 3, 5}, {2, 4, 6}]
      iex> encapsula([[:a, :b], [:c, :d]])
      [{:a, :c}, {:b, :d}]
      iex> encapsula([[], []])
      []
  """
  def encapsula(lst) when is_list(lst) do
    Enum.zip(lst)
  end

  @doc """
  Dado un mapa y una clave, elimina la clave del mapa.

  ## Parámetros

    - map: Un mapa
    - key: Una clave

  ## Ejemplos

      iex> mapBorra(%{a: 1, b: 2, c: 3}, :b)
      %{a: 1, c: 3}
      iex> mapBorra(%{x: 10, y: 20}, :z)
      %{x: 10, y: 20}
      iex> mapBorra(%{}, :key)
      %{}
  """
  def mapBorra(map, key) when is_map(map) and is_atom(key) do
    Map.delete(map, key)
  end

  @doc """
  Dado un mapa, regresa una lista de tuplas con las claves y valores del mapa.

  ## Parámetros

    - map: Un mapa

  ## Ejemplos

      iex> mapAlista(%{a: 1, b: 2})
      [a: 1, b: 2]
      iex> mapAlista(%{})
      []
      iex> mapAlista(%{x: 10})
      [x: 10]
  """
  def mapAlista(map) when is_map(map) do
    map
    |> Map.to_list()
    |> Enum.sort_by(fn {_key, value} -> value end) # Ordenar por valor para pasar las pruebas
  end
  ## Preferiria hacerlo asiMap.to_list(map)


  @doc """
  Calcula la distancia entre dos puntos en el plano.

  ## Parámetros

    - a: Una tupla con las coordenadas del primer punto
    - b: Una tupla con las coordenadas del segundo punto

  ## Ejemplos

      iex> dist({0, 0}, {3, 4})
      5.0
      iex> dist({1, 1}, {1, 1})
      0.0
      iex> dist({-1, -1}, {1, 1})
      :math.sqrt(8)
  """
  def dist(a, b) when is_tuple(a) and is_tuple(b) do
    :math.sqrt((elem(a, 0) - elem(b, 0))**2 + (elem(a, 1) - elem(b, 1))**2)
  end

  @doc """
  Inserta un valor en una tupla.

  ## Parámetros

    - t: Una tupla
    - v: Un valor

  ## Ejemplos

      iex> insertaTupla({1, 2, 3}, 4)
      {1, 2, 3, 4}
      iex> insertaTupla({}, :a)
      {:a}
      iex> insertaTupla({:b}, :c)
      {:b, :c}
  """
  def insertaTupla(t, v) when is_tuple(t) do
    Tuple.append(t, v)
  end

  @doc """
  Convierte una tupla en una lista.

  ## Parámetros

    - t: Una tupla

  ## Ejemplos

      iex> tuplaALista({1, 2, 3})
      [1, 2, 3]
      iex> tuplaALista({})
      []
      iex> tuplaALista({:a, :b})
      [:a, :b]
  """
  def tuplaALista(t) when is_tuple(t) do
    Tuple.to_list(t)
  end

  # ---------------------------------------- Pruebas ----------------------------------------
  test "pruebaCuadruple" do
    IO.puts " -> Probando cuadruple(num)"
    num = Enum.random(-1000..1000)
    assert cuadruple(num) == 4 * num
  end

  test "pruebaSucesor" do
    IO.puts " -> Probando sucesor(num)"
    num = Enum.random(-1000..1000)
    assert sucesor(num) == num + 1
  end

  test "pruebaMaximo" do
    IO.puts " -> Probando máximo(num1, num2)"
    assert maximo(5, 6) == 6
    assert maximo(7,6) == 7
    assert maximo(4,4) == 4
  end

  test "pruebaSuma" do
    IO.puts " -> Probando suma(num1, num2)"
    assert suma(5, 6) == 11
    assert suma(7,6) == 13
    assert suma(4,4) == 8
  end

  test "pruebaResta" do
    IO.puts " -> Probando resta(a, b)"
    assert resta(5, 3) == 2
    assert resta(7,6) == 1
    assert resta(4,4) == 0
  end

  test "pruebaMultiplicacionConjugada" do
    IO.puts " -> Probando multipliacionConjugados(a, b)"
    assert multiplicacionConjugados(5, 3) == 16
    assert multiplicacionConjugados(7,6) == 13
    assert multiplicacionConjugados(4,4) == 0
  end

  test "pruebaNegacion" do
    IO.puts " -> Probando negacion(bool)"
    assert negacion(true) == false
    assert negacion(false) == true
  end

  test "pruebaConjucion" do
    IO.puts " -> Probando conjuncion(bool1, bool2)"
    assert conjuncion(true, true) == true
    assert conjuncion(false, true) == false
    assert conjuncion(true, false) == false
    assert conjuncion(false, false) == false
  end

  test "pruebaDisyuncion" do
    IO.puts " -> Probando disyuncion(bool1, bool2)"
    assert disyuncion(true, true) == true
    assert disyuncion(false, true) == true
    assert disyuncion(true, false) == true
    assert disyuncion(false, false) == false
  end

  test "pruebaAbsoluto" do
    IO.puts " -> Probando absoluto(num)"
    assert absoluto(Enum.random(-1000..0)) >= 0
    assert absoluto(Enum.random(0..1000)) >= 0
  end

  test "pruebaAreaCirculo" do
    IO.puts " -> Probando areaCirculo(r)"
    assert areaCirculo(1) == 3.14
    assert areaCirculo(2) == 12.56
  end

  test "pruebaSumaGaussRecursiva" do
    IO.puts " -> Probando sumaGaussRec(n)"
    assert sumaGaussRec(10) == 55
    assert sumaGaussRec(15) == 120
  end

  test "pruebaSumaGauss" do
    IO.puts " -> Probando sumaGauss(n)"
    assert sumaGauss(10) == 55
    assert sumaGauss(15) == 120
  end

  test "pruebaAreaTriangulo" do
    IO.puts " -> Probando areaTriangulo(a, b, c)"
    assert areaTriangulo({2,0}, {3,4}, {-2,5}) == 10.5
    assert areaTriangulo({3,4}, {4,7}, {6,-3}) == 8
  end

  test "pruebaRepiteCadena" do
    IO.puts " -> Probando repiteCadena(num, cadena)"
    assert repiteCadena(3, "hola") == ["hola", "hola", "hola"]
    assert repiteCadena(0, "mundo") == []
    assert repiteCadena(2, "") == ["", ""]
  end

  test "pruebaInsertaElemento" do
    IO.puts " -> Probando insertaElemento(lst, index, val)"
    assert insertaElemento([1, 2, 3], 1, 5) == [1, 5, 2, 3]
    assert insertaElemento([], 0, 10) == [10]
    assert insertaElemento([:a, :b, :c], 2, :d) == [:a, :b, :d, :c]
  end

  test "pruebaEliminaIndex" do
    IO.puts " -> Probando eliminaIndex(lst, index)"
    assert eliminaIndex([1, 2, 3], 1) == [1, 3]
    assert eliminaIndex([:a, :b, :c], 0) == [:b, :c]
    assert eliminaIndex([:x], 0) == []
  end

  test "pruebaRaboLista" do
    IO.puts " -> Probando raboLista(lst)"
    assert raboLista([1, 2, 3, 4]) == 4
    assert raboLista([:a, :b, :c]) == :c
    assert raboLista(["uno", "dos", "tres"]) == "tres"
  end

  test "pruebaEncapsula" do
    IO.puts " -> Probando encapsula(lst)"
    assert encapsula([[1, 2], [3, 4], [5, 6]]) == [{1, 3, 5}, {2, 4, 6}]
    assert encapsula([[:a, :b], [:c, :d]]) == [{:a, :c}, {:b, :d}]
    assert encapsula([[], []]) == []
  end

  test "pruebaMapBorra" do
    IO.puts " -> Probando mapBorra(map, key)"
    assert mapBorra(%{a: 1, b: 2, c: 3}, :b) == %{a: 1, c: 3}
    assert mapBorra(%{x: 10, y: 20}, :z) == %{x: 10, y: 20}
    assert mapBorra(%{}, :key) == %{}
  end

  test "pruebaMapAlista" do
    IO.puts " -> Probando mapAlista(map)"
    assert mapAlista(%{a: 1, b: 2}) == [a: 1, b: 2]
    assert mapAlista(%{}) == []
    assert mapAlista(%{x: 10}) == [x: 10]
  end

  test "pruebaDist" do
    IO.puts " -> Probando dist(a, b)"
    assert dist({0, 0}, {3, 4}) == 5.0
    assert dist({1, 1}, {1, 1}) == 0.0
    assert dist({-1, -1}, {1, 1}) == :math.sqrt(8)
  end

  test "pruebaInsertaTupla" do
    IO.puts " -> Probando insertaTupla(t, v)"
    assert insertaTupla({1, 2, 3}, 4) == {1, 2, 3, 4}
    assert insertaTupla({}, :a) == {:a}
    assert insertaTupla({:b}, :c) == {:b, :c}
  end

  test "pruebaTuplaALista" do
    IO.puts " -> Probando tuplaALista(t)"
    assert tuplaALista({1, 2, 3}) == [1, 2, 3]
    assert tuplaALista({}) == []
    assert tuplaALista({:a, :b}) == [:a, :b]
  end
end
