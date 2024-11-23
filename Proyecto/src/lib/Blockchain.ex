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
  Inserta un nuevo bloque en la blockchain.
  Verifica que el hash del último bloque coincida con el prev_hash del nuevo bloque.
  """
  def insert(data, %Blockchain{chain: chain} = blockchain) do
    case List.last(chain) do
      nil ->
        {:error, "La blockchain no tiene un bloque génesis. Usa `Blockchain.new()` para inicializarla."}

      last_block ->
        new_block = Block.new(data, last_block.hash)
        updated_chain = chain ++ [new_block]
        {:ok, %Blockchain{blockchain | chain: updated_chain}}
    end
  end
end
