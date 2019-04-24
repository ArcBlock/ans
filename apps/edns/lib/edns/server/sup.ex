defmodule Edns.Server.Sup do
  use Supervisor

  alias Edns.Server.Udp

  def start_link(_) do
    Supervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(_) do
    Supervisor.init(define_servers(), strategy: :one_for_one)
  end

  @doc false
  defp define_servers do
    servers = Edns.Config.get_servers()

    servers
    |> Enum.map(fn server ->
      define_server(server)
    end)
    |> List.flatten()
  end

  @doc false
  defp define_server(server) do
    define_server(server, Map.get(server, :processes), [])
  end

  @doc false
  defp define_server(_, 0, res) do
    res
  end

  defp define_server(%{name: name} = server, 1 = n, []) do
    id = String.to_atom("Edns.Server.Udp.#{name}.#{n}")
    %{id: id, start: {Udp, :start_link, [Map.put(server, :id, id)]}}
  end

  defp define_server(%{name: name} = server, n, res) do
    id = String.to_atom("Edns.Server.Udp.#{name}.#{n}")

    args =
      server
      |> Map.put(:id, id)
      |> Map.put(:socket_options, socket_options())

    define_server(server, n - 1, [
      Supervisor.child_spec({Udp, args}, id: id) | res
    ])
  end

  @doc false
  defp socket_options do
    case :os.type() do
      {:unix, :linux} -> [{:raw, 1, 15, <<1, 0, 0, 0>>}]
      {:unix, :darwin} -> [{:raw, 65535, 512, <<1, 0, 0, 0>>}]
      _ -> []
    end
  end

  # __end_of_module__
end
