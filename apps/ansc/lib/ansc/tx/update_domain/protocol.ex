defmodule CoreTx.UpdateDomain do
  defmodule Rpc do
    import ForgeSdk.Tx.Builder, only: [tx: 2]
    tx(:update_domain, multisig: true)
  end

  defmodule UpdateTx do
    @moduledoc """
    update domain pipe
    """
    use ForgePipe.Builder

    def init(opts), do: opts

    def call(%{tx: tx, itx: itx} = info, opts) do
      Logger.debug(fn -> "[pipe - update_domain/update]: from #{tx.from}, to #{itx.address}" end)

      info
      |> update_owner()
      |> update_domain(opts)
      |> put_status(:ok)
    end

    # private function
    defp update_owner(%{tx: tx, sender_state: owner_state, context: context} = info) do
      attrs = %{nonce: tx.nonce}
      owner_state = CoreState.Account.update(owner_state, attrs, context)

      :ok = info.db_handler.put!(owner_state.address, owner_state)
      put(info, :sender_state, owner_state)
    end

    defp update_domain(%{itx: itx, context: context} = info, opts) do
      path = opts[:asset] || [:priv, :asset]
      domain = get(info, path)
      attrs = itx |> Map.from_struct() |> Map.delete(:address)

      domain_state = CoreState.Asset.update(domain, attrs, context)
      :ok = info.db_handler.put!(itx.address, domain_state)
      put(info, path, domain_state)
    end
  end
end
