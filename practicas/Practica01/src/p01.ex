ExUnit.start() # framework para pruebas unitarias en elixir

defmodule P01 do
  @moduledoc """
  Modulo con las funciones de la practica01
  """
  use ExUnit.Case # usamos el framework de pruebas caso por caso


  @doc """
    Calcula el cuádruple de un número

    ## Parámetros 

      - x: Número entero

    """
  def cuadruple(x) do
    if is_integer(x) do 
      x*4
    end
  end

  @doc """
   Devuelve el sucesor de un número entero.
  
  ## Parámetros 
  
  -x: Número entero 
  
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
  def maximo(x,y) do
    if is_integer(x) && is_integer(y) do    
      cond do
        x>=y -> 
            x
        x<y ->
            y
      end
    end
  end
  
  @doc """
  Suma dos números enteros.
  
  ## Parámetros 
  
  -x: Número a sumar
  -y: Número a sumar 
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
  def resta(x,y) do
    if is_integer(x) && is_integer(y) do  
      x-y 
    end
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
  def negacion(x) do
    if is_boolean(x) do  
      !x
    end
  end

  @doc """
  Realiza la conjunción lógica entre dos valores booleanos.
  
  ## Parámetros 
  
  -x: Primer término booleano para la conjunción 
  -y: Segundo término booleano para la conjunción 
  """
  def conjuncion?(x, y) when is_boolean(x) and is_boolean(y) do
    x and y
  end

  def conjuncion?(_x, _y) do
    raise ArgumentError, "Ambos argumentos deben ser booleanos."
  end

   @doc """
    Devuelve la disyunción de dos valores booleanos

    ## Parámetros 

      - x: Primer booleano
      - y: Segundo booleano

    """
  def disyuncion(x,y) do
    if is_boolean(x) && is_boolean(y) do  
      x || y
    end
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
  def areaCirculo(r) do
     if is_integer(r) do
        3.14 * r * r
     end
  end

  @doc """
  Calcula la suma de Gauss de un número entero n de manera recursiva.
  
  ## Parámetros 
  -n: Número para hacer la suma de Gauss
  """
  def suma_gauss(0) do
    0
  end

  def suma_gauss(n) when is_integer(n) and n > 0 do
    n + suma_gauss(n - 1)
  end

  def suma_gauss(_n) do
    raise ArgumentError, "El argumento debe ser un número entero positivo o 0."
  end

  @doc """
    Calcula la suma de Gauss con la fórmula cerrada

    ## Parametros

      - n: Número entero a calcular la suma 

    """
  def sumaGauss(n) do
    if is_integer(n) && is_integer(n) do  
      div(n * (n + 1), 2) 
    end
  end   

  @doc """
  Calcula el área de un triángulo dados tres puntos en el plano.
  
  ## Parámetros 
  
  -{x1, y1}, {x2, y2}, {x3, y3}: Tres duplas de numeros enteros que representan las coordenadas 
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

    """
  def repiteCadena(x,cadena) do
    if is_integer(x) do
      case x do
        0 -> []
        x ->
          [cadena] ++ repiteCadena(x - 1, cadena)
      end
    end
  end

  @doc """
  Inserta un valor en una lista en el índice especificado.
  
  ## Parámetros 
  
  -lista: Una lista de números 
  -i: Número entero que representa el índice 
  -v: Número entero que representa el valor 
  """
  def insertaElemento(lista, i, v) do 
    izquierda = Enum.take(lista, i)
    derecha = Enum.drop(lista, i)
    izquierda ++ [v] ++ derecha
  end

  # ---------------------------------------- Pruebas ----------------------------------------

  test "pruebaSucesor" do
    IO.puts " -> Probando sucesor(num)"
    num = Enum.random(-1000..1000)
    assert sucesor(num) == num + 1
  end

  test "pruebaSuma" do
    IO.puts " -> Probando suma(num1, num2)"
    assert suma(5, 6) == 11
    assert suma(7, 6) == 13
    assert suma(4, 4) == 8
  end

  test "pruebaMultiplicacionConjugada" do
    IO.puts " -> Probando multiplicacionConjugados(a, b)"
    assert multiplicacionConjugados(5, 3) == 16
    assert multiplicacionConjugados(7, 6) == 13
    assert multiplicacionConjugados(4, 4) == 0
  end

  test "pruebaConjuncion" do
    IO.puts " -> Probando conjuncion(bool1, bool2)"
    assert conjuncion?(true, true) == true
    assert conjuncion?(false, true) == false
    assert conjuncion?(true, false) == false
    assert conjuncion?(false, false) == false
  end

  test "pruebaAbsoluto" do
    IO.puts " -> Probando absoluto(num)"
    assert absoluto(Enum.random(-1000..0)) >= 0
    assert absoluto(Enum.random(0..1000)) >= 0
  end

  test "pruebaSumaGaussRecursiva" do
    IO.puts " -> Probando sumaGaussRec(n)"
    assert suma_gauss(10) == 55
    assert suma_gauss(15) == 120
  end

  test "pruebaAreaTriangulo" do
    IO.puts " -> Probando areaTriangulo(a, b, c)"
    assert areaTriangulo({2, 0}, {3, 4}, {-2, 5}) == 10.5
    assert areaTriangulo({3, 4}, {4, 7}, {6, -3}) == 8
  end


test "pruebaInsertaElemento" do
    IO.puts " -> Probando insertaElemento(lst, index, val)"
    assert insertaElemento([1, 2, 3], 1, 5) == [1, 5, 2, 3]
    assert insertaElemento([], 0, 10) == [10]
    assert insertaElemento([:a, :b, :c], 2, :d) == [:a, :b, :d, :c]
  end


test "pruebaCuadruple" do
    IO.puts " -> Probando cuadruple(num)"
    num = Enum.random(-1000..1000)
    assert cuadruple(num) == 4 * num
  end
    
  test "pruebaMaximo" do
    IO.puts " -> Probando máximo(num1, num2)"
    assert maximo(5, 6) == 6
    assert maximo(7,6) == 7
    assert maximo(4,4) == 4
  end 
      
    test "pruebaResta" do
    IO.puts " -> Probando resta(a, b)"
    assert resta(5, 3) == 2
    assert resta(7,6) == 1
    assert resta(4,4) == 0
  end
    
      test "pruebaNegacion" do
    IO.puts " -> Probando negacion(bool)"
    assert negacion(true) == false
    assert negacion(false) == true
  end

     test "pruebaDisyuncion" do
    IO.puts " -> Probando disyuncion(bool1, bool2)"
    assert disyuncion(true, true) == true
    assert disyuncion(false, true) == true
    assert disyuncion(true, false) == true
    assert disyuncion(false, false) == false
  end
    
      test "pruebaAreaCirculo" do
    IO.puts " -> Probando areaCirculo(r)"
    assert areaCirculo(1) == 3.14
    assert areaCirculo(2) == 12.56
  end
    
      test "pruebaSumaGauss" do
    IO.puts " -> Probando sumaGauss(n)"
    assert sumaGauss(10) == 55
    assert sumaGauss(15) == 120
  end
    
      test "pruebaRepiteCadena" do
    IO.puts " -> Probando repiteCadena(num, cadena)"
    assert repiteCadena(3, "hola") == ["hola", "hola", "hola"]
    assert repiteCadena(0, "mundo") == []
    assert repiteCadena(2, "") == ["", ""]
  end   
end


# Corre las pruebas cuando se carga el archivo
ExUnit.start()
