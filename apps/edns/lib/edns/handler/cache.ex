defmodule Edns.Handler.Cache.Exp do
  @moduledoc false

  use Mcc.Model.Table,
    table_opts: [
      type: :ordered_set,
      disc_copies: [node()],
      storage_properties: [
        ets: [:compressed, read_concurrency: true]
      ]
    ]

  defstruct [:key, :value]
end

defmodule Edns.Handler.Cache do
  @moduledoc false

  alias Edns.Handler.Cache.Exp, as: HandlerExp

  use Mcc.Model.Table,
    table_opts: [
      type: :set,
      disc_copies: [node()],
      storage_properties: [
        ets: [:compressed, read_concurrency: true]
      ]
    ],
    expiration_opts: [
      expiration_table: HandlerExp,
      main_table: __MODULE__,
      size_limit: 100,
      # 300M
      memory_limit: 300,
      waterline_ratio: 0.7,
      check_interval: 1_000
    ]

  defstruct([:key, :value], true)

  def get_with_ttl(k) do
    case get(k) do
      %{key: ^k, value: value} -> value
      _ -> nil
    end
  end

  def put_with_ttl(k, v, ttl \\ 10) do
    put(k, %__MODULE__{key: k, value: v}, ttl)
    v
  end

  #
end
