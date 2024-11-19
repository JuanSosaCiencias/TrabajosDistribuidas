defmodule Block do
  defstruct [:data, :timestamp, :prev_hash, :hash]

  def new(data, prev_hash) do
    timestamp = DateTime.utc_now() |> DateTime.to_string()
    # Usamos Crypto.put_hash para obtener el hash del bloque
    block = %Block{
      data: data,
      timestamp: timestamp,
      prev_hash: prev_hash,
      hash: ""
    }

    # Insertamos el hash en el bloque
    Crypto.put_hash(block)
  end

  def valid?(%Block{hash: hash} = block) do
    hash == Crypto.hash(block)
  end

  def valid?(%Block{hash: current_hash} = current_block, %Block{hash: prev_hash} = _previous_block) do
    current_block.prev_hash == prev_hash and current_hash == Crypto.hash(current_block)
  end
end


defmodule Blockchain do
  defstruct chain: []

  def new_genesis_block do
    block = %Block{
      data: "Genesis Block",
      timestamp: "2024-01-01 00:00:00Z",
      prev_hash: "0",
      hash: ""
    }

    Crypto.put_hash(block)
  end

  @doc "Crea una nueva blockchain con un bloque génesis"
  def new() do
    genesis_block = new_genesis_block()
    %Blockchain{chain: [genesis_block]}
  end

  @doc "Inserta un bloque nuevo en la blockchain y retorna el nuevo bloque actual"
  def insert_and_return_block(%Blockchain{chain: chain} = blockchain, data) do
    last_block = List.last(chain)
    new_block = Block.new(data, last_block.hash)

    if Block.valid?(new_block, last_block) do
      IO.puts("Bloque insertado exitosamente con hash #{new_block.hash}")
      updated_chain = chain ++ [new_block]
      {%Blockchain{chain: updated_chain}, new_block}
    else
      IO.puts("Error: El bloque es inválido y no se insertará")
      {blockchain, List.last(chain)}
    end
  end

  @doc "Valida toda la blockchain"
  def valid?(%Blockchain{chain: chain}) do
    Enum.chunk_every(chain, 2, 1, :discard)
    |> Enum.all?(fn [prev, next] -> Block.valid?(next, prev) end)
  end
end
