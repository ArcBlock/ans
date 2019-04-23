defmodule Ansc.Lib do
  @moduledoc false

  alias CoreTx.CreateDomain.Rpc
  alias ForgeAbi.CreateDomainTx
  alias Google.Protobuf.Any

  @doc """

  """
  def create_wallet(passphrase, moniker) do
    ForgeSdk.create_wallet(moniker: moniker, passphrase: passphrase)
  end

  @doc """

  """
  def create_domain(wallet, token, domain, zone_info) do
    {domain_address, domain_itx} = create_domain_itx(wallet, domain, zone_info)

    {domain_address,
     ForgeSdk.send_tx(
       tx: Rpc.create_domain(domain_itx, wallet: wallet, token: token, send: :nosend)
     )}
  end

  @doc false
  defp create_domain_itx(wallet, domain, zone_info) do
    domain_itx =
      CreateDomainTx.new(data: Any.new(type_url: domain, data: zone_info), transferrable: true)

    {ForgeSdk.Util.to_asset_address(wallet.address, domain_itx), domain_itx}
  end

  @doc """

  """
  def get_domain_by_address(domain_address) do
    [address: domain_address]
    |> ForgeSdk.get_asset_state()
    |> Map.get(:data, %{})
    |> Map.drop([:__struct__])
  end

  # __end_of_module__
end
