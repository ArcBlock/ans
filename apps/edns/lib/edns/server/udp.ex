defmodule Edns.Server.Udp do
  @moduledoc false

  use GenServer

  require Logger

  alias Edns.Server.UdpWorker

  @default_udp_recbuf 1024 * 1024

  def start_link(%{id: id} = args) do
    GenServer.start_link(__MODULE__, args, name: id, hibernate_after: 100)
  end

  def worker_pool do
    [
      {:name, {:local, worker_pool_name()}},
      {:worker_module, UdpWorker},
      {:size, System.schedulers_online() * 8},
      {:max_overflow, System.schedulers_online() * 8}
    ]
  end

  def worker_pool_name do
    Edns.Server.Udp.WorkerPool
  end

  def init(%{address: address, port: port, family: family} = args) do
    {:ok, socket} = start(address, port, family, Map.get(args, :socket_options, []))
    {:ok, %{address: address, port: port, socket: socket}}
  end

  def handle_info({:udp, socket, host, port, bin}, %{socket: socket} = state) do
    handle_request(socket, host, port, bin)
    :inet.setopts(socket, active: 100)
    {:noreply, state}
  end

  @doc false
  defp start(address, port, family, socket_options) do
    case(
      :gen_udp.open(port, [
        :binary,
        {:active, 100},
        {:reuseaddr, true},
        {:read_packets, 1000},
        {:ip, address},
        {:recbuf, @default_udp_recbuf},
        family | socket_options
      ])
    ) do
      {:ok, socket} ->
        Logger.info("UDP server started: #{family} - #{inspect(socket)} - #{port}")
        {:ok, socket}

      error ->
        Logger.error("UDP server started error, error: #{inspect(error)}")
        :error
    end
  end

  @doc false
  defp handle_request(socket, host, port, bin) do
    spawn(fn ->
      :poolboy.transaction(
        worker_pool_name(),
        fn pid -> UdpWorker.handle_request(pid, socket, host, port, bin) end
      )
    end)
  end

  # __end_of_module__
end
