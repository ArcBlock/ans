defmodule CoreTx.CreateDomain do
  defmodule Rpc do
    import ForgeSdk.Rpc.Tx.Builder, only: [tx: 1]
    tx(:create_domain)
  end

  defmodule UpdateTx do
    @moduledoc """
    create asset pipe
    """
    use ForgePipe.Builder
    alias ForgeAbi.AssetState
    alias ForgeSdk.State

    def init(opts), do: opts

    def call(%{tx: tx} = info, opts) do
      Logger.debug(fn -> "[pipe - create_asset/update]: from #{tx.from}." end)

      address = get(info, opts[:address])

      info
      |> update_owner()
      |> update_asset(address)
      |> put_status(:ok)
    end

    # private function
    defp update_owner(%{tx: tx, sender_state: owner_state, context: context} = info) do
      attrs = %{nonce: tx.nonce, num_assets: owner_state.num_assets + 1}
      owner_state = State.update(owner_state, attrs, context)

      :ok = info.db_handler.put!(owner_state.address, owner_state)
      %{info | sender_state: owner_state}
    end

    defp update_asset(%{itx: itx, context: context} = info, asset_address) do
      %{address: address} = info.sender_state

      attrs =
        itx
        |> Map.from_struct()
        |> Map.put(:owner, address)
        |> Map.put(:address, asset_address)
        |> Map.put(:issuer, address)
        |> Map.put(:transferrable, true)

      asset_state = State.create(%AssetState{}, attrs, context)
      :ok = info.db_handler.put!(asset_address, asset_state)
      put(info, [:priv, :asset], asset_state)
    end
  end

  defmodule UpdateLocalDb do
    use ForgePipe.Builder
    def init(opts), do: opts

    def call(info, _opts) do
      info |> IO.inspect()
    end
  end

  # __end_of_module__
end
