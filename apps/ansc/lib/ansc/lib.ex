defmodule Ansc.Lib do
  @moduledoc false

  alias Ansc.Cache.Domain
  alias CoreTx.RegisterDomain.Rpc, as: CreateRpc
  alias CoreTx.UpdateDomain.Rpc, as: UpdateRpc
  alias ForgeAbi.{RegisterDomainTx, UpdateDomainTx}
  alias Google.Protobuf.Any

  @doc """

  """
  def create_wallet(passphrase, moniker) do
    ForgeSdk.create_wallet(moniker: moniker, passphrase: passphrase)
  end

  @doc """

  """
  def register_domain(wallet, token, domain, zone_info) do
    domain_itx = register_domain_itx(domain, zone_info)

    ForgeSdk.send_tx(
      tx: CreateRpc.register_domain(domain_itx, wallet: wallet, token: token, send: :nosend)
    )
  end

  @doc false
  defp register_domain_itx(domain, zone_info) do
    RegisterDomainTx.new(
      data: Any.new(type_url: domain, value: zone_info),
      transferrable: true,
      address: domain
    )
  end

  @doc """

  """
  def update_domain(wallet, token, domain, zone_info) do
    domain_itx = update_domain_itx(domain, zone_info)

    ForgeSdk.send_tx(
      tx: UpdateRpc.update_domain(domain_itx, wallet: wallet, token: token, send: :nosend)
    )
  end

  @doc false
  defp update_domain_itx(domain, zone_info) do
    UpdateDomainTx.new(
      data: Any.new(type_url: domain, value: zone_info),
      address: domain
    )
  end

  @doc """

  """
  def get_domain(domain) do
    case Domain.get_with_ttl(domain) do
      :"$not_can_found" ->
        domain
        |> get_domain_by_address_from_forge()
        |> maybe_create_cache(domain)

      zone ->
        zone
    end
  end

  @doc false
  defp get_domain_by_address_from_forge(domain) do
    [address: domain]
    |> ForgeSdk.get_asset_state()
    |> case do
      nil ->
        nil

      state ->
        state
        |> Map.get(:data, %{})
        |> Map.get(:value, "")
    end
  end

  @doc false
  defp maybe_create_cache(zone, _domain), do: zone

  # __end_of_module__
end
