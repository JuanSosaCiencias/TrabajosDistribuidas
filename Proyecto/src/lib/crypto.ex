defmodule Crypto do
  @moduledoc """
  Módulo que asegura la integridad de los bloques utilizando funciones de hashing criptográfico.
  """
  @block_fields [:data, :timestamp, :prev_hash]

  @doc """
  Calcula el hash de un bloque.

  ## Parámetros:
  - `block`: El bloque a calcular su hash

  ## Retorna:
  Una cadena que es el hash del bloque.
  """
  def hash(%{} = block) do
    block
    |> Map.take(@block_fields)
    |> encode_to_binary()
    |> simple_hash()
  end

  @doc """
  Calcula e inserta el hash en el bloque

  ## Parámetros:
  - `block`: Un bloque.

  ## Retorna:
  El bloque con el campo `:hash` añadido.
  """
  def put_hash(%{} = block) do
    %{block | hash: hash(block)}
  end

  defp encode_to_binary(map) do
    map
    |> Enum.map(fn {_, value} -> to_binary(value) end)
    |> Enum.join()
    |> :erlang.binary_to_list()
  end

  defp to_binary(value) when is_binary(value), do: value
  defp to_binary(value), do: inspect(value)

  defp simple_hash(binary) do
    :erlang.phash2(binary) |> Integer.to_string(16)
  end
end
