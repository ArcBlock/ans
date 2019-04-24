defmodule Edns.Config do
  @moduledoc false

  def get_servers do
    :edns
    |> Application.get_env(:servers, [])
    |> Enum.map(fn server ->
      %{
        name: Keyword.get(server, :name),
        address: parse_address(Keyword.get(server, :address)),
        port: Keyword.get(server, :port),
        family: Keyword.get(server, :family),
        processes: Keyword.get(server, :processes, 1)
      }
    end)
  end

  @doc false
  defp parse_address(address) when is_bitstring(address) do
    address
    |> String.to_charlist()
    |> :inet_parse.address()
    |> elem(1)
  end

  # __end_of_module__
end
