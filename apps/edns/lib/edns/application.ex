defmodule Edns.Application do
  @moduledoc false

  use Application

  alias Edns.Server.Udp

  def start(_type, _args) do
    children = [Edns.Server.Sup, udp_worker_pool()]
    opts = [strategy: :one_for_one, name: Edns.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @doc false
  defp udp_worker_pool do
    :poolboy.child_spec(Udp.worker_pool_name(), Udp.worker_pool(), [])
  end

  # __end_of_module__
end
