defmodule CoreTx.RegisterDomain do
  defmodule Rpc do
    import ForgeSdk.Tx.Builder, only: [tx: 2]
    tx(:register_domain, multisig: true)
  end

  defmodule ExtractDomainAddress do
    use ForgePipe.Builder
    def init(opts), do: opts

    def call(%{itx: itx} = info, opts) do
      status =
        case itx.address === "" do
          true -> :invalid_asset
          false -> :ok
        end

      info
      |> put(opts[:to], itx.address)
      |> put_status(status)
    end
  end

  defmodule ExtractDomainValue do
    use ForgeAbi.Unit
    use ForgePipe.Builder

    def init(opts), do: opts

    def call(info, opts) do
      info
      |> put(opts[:to], biguint(opts[:value]))
      |> put_status(:ok)
    end
  end

  defmodule UpdateTx do
    @moduledoc """
    Register domain pipe
    """
    use ForgeAbi.Unit
    use ForgePipe.Builder
    alias ForgeAbi.AssetState

    def init(opts), do: opts

    def call(%{tx: tx} = info, opts) do
      Logger.debug(fn -> "[pipe - register_domain/update]: from #{tx.from}." end)

      address = get(info, opts[:address])

      info
      |> update_balance(opts)
      |> update_owner()
      |> update_asset(address)
      |> put_status(:ok)
    end

    @doc false
    defp update_balance(%{sender_state: sender_state, db_handler: handler} = info, opts) do
      domain_value = to_uint(get(info, opts[:value]))
      bill_collector = opts[:bill_collector]

      new_sender_state =
        CoreState.Account.update(
          sender_state,
          %{
            nonce: info.tx.nonce,
            balance: sender_state.balance - domain_value
          },
          info.context
        )

      :ok = handler.put!(sender_state.address, new_sender_state)
      receiver_state = handler.get(bill_collector)

      new_receiver_state =
        CoreState.Account.update(
          receiver_state,
          %{balance: receiver_state.balance + domain_value},
          info.context
        )

      :ok = handler.put!(bill_collector, new_receiver_state)

      info
      |> put(:sender_state, new_sender_state)
      |> put_status(:ok)
    end

    # private function
    defp update_owner(%{tx: tx, sender_state: owner_state, context: context} = info) do
      attrs = %{nonce: tx.nonce, num_assets: owner_state.num_assets + 1}
      owner_state = CoreState.Account.update(owner_state, attrs, context)

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

      asset_state = CoreState.Asset.create(AssetState.new(), attrs, context)
      :ok = info.db_handler.put!(asset_address, asset_state)
      put(info, [:priv, :asset], asset_state)
    end
  end

  # __end_of_module__
end
