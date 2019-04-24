defmodule Edns.Server.UdpWorker do
  @moduledoc false

  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, hibernate_after: 100)
  end

  def handle_request(worker_pid, socket, host, port, bin) do
    GenServer.call(worker_pid, {:handle_request, socket, host, port, bin})
  end

  def init(_) do
    {:ok, %{}}
  end

  def handle_call({:handle_request, socket, host, port, bin}, _from, state) do
    case Edns.decode_message(bin) do
      {:trailing_garbage, decoded_message, _} ->
        handle_process(decoded_message, socket, port, host)

      {_, _, _} ->
        :ok

      decoded_message ->
        handle_process(decoded_message, socket, port, host)
    end

    {:reply, :ok, state}
  end

  @doc false
  defp handle_process(decoded_message, socket, port, host) do
    resp = Edns.Handler.handle(decoded_message, {:udp, host})

    case Edns.encode_message(resp, max_size: 4096) do
      {false, encoded_msg} ->
        :gen_udp.send(socket, host, port, encoded_msg)

      {true, encoded_msg, %{__struct__: DnsMessage} = _message} ->
        :gen_udp.send(socket, host, port, encoded_msg)

      {false, encoded_msg, _} ->
        :gen_udp.send(socket, host, port, encoded_msg)

      {true, encoded_msg, _, _} ->
        :gen_udp.send(socket, host, port, encoded_msg)
    end
  end

  # __end_of_module__
end
