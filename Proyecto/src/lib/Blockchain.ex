defmodule Block do
  defstruct [:data, :timestamp, :prev_hash, :hash]

  def new(data, prev_hash) do
    timestamp = DateTime.utc_now() |> DateTime.to_string()
    block = %Block{
      data: data,
      timestamp: timestamp,
      prev_hash: prev_hash,
      hash: ""
    }

    # Insertamos el hash en el bloque
    Crypto.put_hash(block)
  end

  @doc """
  Valida un bloque individual.
  """
  def valid?(%Block{} = block) do
    block.hash == Crypto.hash(block)
  end

  @doc """
  Valida si dos bloques secuenciales son válidos.
  Incluye la validación de `prev_hash` y del orden temporal.
  """
  def valid?(%Block{} = block1, %Block{} = block2) do
    block2.prev_hash == block1.hash and block1.timestamp <= block2.timestamp and Block.valid?(block1) and Block.valid?(block2)
  end

end


defmodule Blockchain do
  defstruct chain: []

  @doc "Crea el bloque génesis de la blockchain"
  def new_genesis_block do
    block = %Block{
      data: "Genesis Block",
      timestamp: "2024-01-01 00:00:00Z",
      prev_hash: "0",
      hash: ""
    }

    Crypto.put_hash(block) # Usa el módulo `Crypto` para calcular el hash
  end

  @doc "Crea una nueva blockchain con un bloque génesis"
  def new() do
    genesis_block = new_genesis_block()
    %Blockchain{chain: [genesis_block]}
  end

  @doc """
  Valida la blockchain completa.
  Incluye validaciones de hashes, `prev_hash` y orden temporal.
  """
  def valid?(%Blockchain{chain: chain}) do
    chain
    |> Enum.chunk_every(2, 1, :discard) # Obtiene pares consecutivos
    |> Enum.all?(fn
      [block1, block2] -> Block.valid?(block1, block2)
      [block] -> Block.valid?(block)
    end)
  end

  @doc """
  Inserta un nuevo bloque en la blockchain.
  Valida que el bloque sea consistente antes de insertarlo.
  """
  def insert(%Block{} = new_block, %Blockchain{chain: chain} = blockchain) do
    case List.last(chain) do
      nil ->
        {:error, "La blockchain no tiene un bloque génesis. Usa `Blockchain.new()` para inicializarla."}

      last_block ->
        if Block.valid?(last_block, new_block) do
          updated_chain = chain ++ [new_block]
          {:ok, %Blockchain{blockchain | chain: updated_chain}}
        else
          {:error, "El nuevo bloque no es válido"}
        end
    end
  end
end
