defmodule Ansc.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # forgesdk init env
    ForgeSdk.init(:forge) |> IO.inspect()
    Application.get_env(:forge_sdk, :otp_app, :undefined) |> IO.inspect
    Application.get_env(:forge, :forge_config) |> IO.inspect
    ForgeSdk.get_env(:forge_config) |> IO.inspect
    # install_domain_tx()
    children = []
    Supervisor.start_link(children, strategy: :one_for_one, name: Ansc.Supervisor)
  end

  @doc false
  def install_domain_tx do
    install_tx("/Users/redink/arcblock/github/ans/apps/ansc/lib/ansc/tx/create_domain/create_domain.itx.json")
  end

  @doc false
  defp install_tx(file_name) do
    itx =
      file_name
      |> File.read!()
      |> Jason.decode!()
      |> Map.get("create_domain")
      |> Base.url_decode64!(padding: false)
      |> ForgeAbi.DeployProtocolTx.decode()

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
    ForgeSdk.deploy_protocol(itx, wallet: wallet)
  end

  # __end_of_module__
end
