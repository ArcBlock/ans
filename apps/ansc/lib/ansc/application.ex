defmodule Ansc.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # forgesdk init env
    ForgeSdk.init(:ansc)
    install_domain_tx()
    add_type_urls()
    children = []
    Supervisor.start_link(children, strategy: :one_for_one, name: Ansc.Supervisor)
  end

  @doc false
  def install_domain_tx do
    wallet = new_wallet()

    install_tx(
      "/Users/redink/arcblock/github/ans/apps/ansc/lib/ansc/tx/register_domain/register_domain.itx.json",
      "register_domain",
      wallet
    )

    install_tx(
      "/Users/redink/arcblock/github/ans/apps/ansc/lib/ansc/tx/update_domain/update_domain.itx.json",
      "update_domain",
      wallet
    )
  end

  @doc false
  defp new_wallet do
    wallet =
      ForgeAbi.WalletInfo.new(
        address: "z11N3R6GZrNingR11Dub9EbVMJGgyZTJGMQB",
        pk: Base.url_decode64!("EyNstcu1Jk9FPgtDT9QJMkW-gh6ihSm6Atj9I412G6Q", padding: false),
        sk:
          Base.url_decode64!(
            "Z0K5K2Vv_v00NLNiM4AqzMfcHeZKQoTM0kyxd1h9EmQTI2y1y7UmT0U-C0NP1AkyRb6CHqKFKboC2P0jjXYbpA",
            padding: false
          )
      )

    ForgeSdk.declare(ForgeAbi.DeclareTx.new(moniker: "moderator"), wallet: wallet)
    wallet
  end

  @doc false
  defp install_tx(file_name, action_name, wallet) do
    file_name
    |> File.read!()
    |> Jason.decode!()
    |> Map.get(action_name)
    |> Base.url_decode64!(padding: false)
    |> ForgeAbi.DeployProtocolTx.decode()
    |> ForgeSdk.deploy_protocol(wallet: wallet)
  end

  @doc false
  defp add_type_urls do
    ForgeAbi.add_type_url("fg:t:register_domain", ForgeAbi.RegisterDomainTx)
    ForgeAbi.add_type_url("fg:t:update_domain", ForgeAbi.UpdateDomainTx)
  end

  # __end_of_module__
end
