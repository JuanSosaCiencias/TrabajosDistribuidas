defmodule Crypto do

  @block_fields [:data, :timestamp, :prev_hash]

  @doc "Calcula el hash de un bloque"
  def hash(%{} = block) do
    block
    |> Map.take(@block_fields)
    |> encode_to_binary()
    |> simple_hash()
  end

  @doc "Calcula e inserta el hash en el bloque"
  def put_hash(%{} = block) do
    %{block | hash: hash(block)}
  end

  # ChatGPT me ayudó porque encode no acepta no binarios
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
