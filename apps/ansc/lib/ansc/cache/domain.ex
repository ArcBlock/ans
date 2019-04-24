defmodule Ansc.Cache.Domain.Exp do
  @moduledoc false

  use Mcc.Model.Table,
    table_opts: [
      type: :ordered_set,
      ram_copies: [node()],
      storage_properties: [
        ets: [:compressed, read_concurrency: true]
      ]
    ]

  defstruct [:key, :value]
end

defmodule Ansc.Cache.Domain do
  @moduledoc false

  alias Ansc.Cache.Domain.Exp, as: DomainExp

  use Mcc.Model.Table,
    table_opts: [
      type: :set,
      ram_copies: [node()],
      storage_properties: [
        ets: [:compressed, read_concurrency: true]
      ]
    ],
    expiration_opts: [
      expiration_table: DomainExp,
      main_table: __MODULE__,
      size_limit: 1000,
      # 300M
      memory_limit: 300,
      waterline_ratio: 0.7,
      check_interval: 1_000
    ]

  defstruct([:domain, :zone], true)

  def get_with_ttl(k) do
    case get(k) do
      %{domain: ^k, zone: zone} -> zone
      _ -> :"$not_can_found"
    end
  end

  def put_with_ttl(k, v, ttl \\ 86_400) do
    put(k, %__MODULE__{domain: k, zone: v}, ttl)
    v
  end

  #
end
