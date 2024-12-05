defmodule Block do
 @moduledoc """
  Módulo que define la estructura y funcionalidades para trabajar con bloques de una blockchain.

  Un bloque contiene:
  - `data`: los datos asociados a la transacción.
  - `timestamp`: fecha y hora de la creación del bloque.
  - `prev_hash`: hash del bloque anterior en la cadena.
  - `hash`: el hash único generado para este bloque.

  """
  defstruct [:data, :timestamp, :prev_hash, :hash]

 @doc """
  Crea un nuevo bloque con el dato que recibe y el hash del bloque antecesor 
  """
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
  Valida un bloque individualmente.

  Verifica que el hash almacenado en el bloque coincida con el hash calculado a partir de sus datos.
  """
  def valid?(%Block{} = block) do
    block.hash == Crypto.hash(block)
  end

  @doc """
  Valida si dos bloques secuenciales son válidos.

  Valida que el `prev_hash` del segundo bloque coincida con el `hash` del primer bloque y que el orden temporal entre los bloques sea correcto.
  """
  def valid?(%Block{} = block1, %Block{} = block2) do
    block2.prev_hash == block1.hash and block1.timestamp <= block2.timestamp and Block.valid?(block1) and Block.valid?(block2)
  end

end


defmodule Blockchain do
 @moduledoc """
  Módulo que realiza operaciones sobre una blockchain.

  Una **blockchain** es una lista de bloques interconectados. 
  """
  defstruct chain: []

  @doc "Crea el bloque génesis de la blockchain."
  def new_genesis_block do
    block = %Block{
      data: "Genesis Block",
      timestamp: "2024-01-01 00:00:00Z",
      prev_hash: "0",
      hash: ""
    }

    Crypto.put_hash(block) # Usa el módulo `Crypto` para calcular el hash
  end

  @doc "Crea una nueva blockchain con un bloque génesis."
  def new() do
    genesis_block = new_genesis_block()
    %Blockchain{chain: [genesis_block]}
  end

  @doc """
  Valida la blockchain completa.

  Se comprueba que:
  - El hash de cada bloque coincida con el valor calculado para ese bloque.
  - El `prev_hash` de cada bloque coincida con el `hash` del bloque anterior.
  - Los bloques esten ordenados cronológicamente).

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

  Verifica que el bloque anterior es válido en relación con el nuevo bloque.
  - Si la validación es exitosa, el nuevo bloque se añade.
  - En otro caso el bloque se descarta.
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
