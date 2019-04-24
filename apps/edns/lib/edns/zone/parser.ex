defmodule Edns.Zone.Parser do
  @moduledoc false

  # %{
  #   name: "withzonecut.com",
  #   records: [
  #     %{
  #       data: %{
  #         expire: 604800,
  #         minimum: 86400,
  #         mname: "ns1.example.com",
  #         refresh: 28800,
  #         retry: 7200,
  #         rname: "ahu.example.com",
  #         serial: 2000081501
  #       },
  #       name: "withzonecut.com",
  #       ttl: 100000,
  #       type: "SOA"
  #     },
  #     %{
  #       data: %{dname: "ns1.example.com"},
  #       name: "withzonecut.com",
  #       ttl: 120,
  #       type: "NS"
  #     },
  #     %{
  #       data: %{exchange: "smtp-servers.example.com", preference: 10},
  #       name: "child.zonecut.withzonecut.com",
  #       ttl: 120,
  #       type: "MX"
  #     },
  #     %{
  #       data: %{dname: "somewhere.else.net"},
  #       name: "cnamerecord.zonecut.withzonecut.com",
  #       ttl: 120,
  #       type: "CNAME"
  #     }
  #   ]
  # },
  def parse(%{name: name, records: record_list}) do
    {name, parse_record_list(record_list)}
  end

  @doc """
  """
  def parse_record_list(record_list) do
    record_list
    |> Enum.map(fn record ->
      case Map.get(record, :data) do
        nil -> nil
        _ -> parse_record(record)
      end
    end)
    |> Enum.uniq()
    |> Enum.reject(&is_nil/1)
  end

  @doc false
  defp parse_record(%{type: "SOA", name: name, ttl: ttl, data: data}) do
    %DnsRr{
      name: name,
      type: SOA,
      data: %DnsRrdataSoa{
        mname: Map.get(data, :mname),
        rname: Map.get(data, :rname),
        serial: Map.get(data, :serial),
        refresh: Map.get(data, :refresh),
        retry: Map.get(data, :retry),
        expire: Map.get(data, :expire),
        minimum: Map.get(data, :minimum)
      },
      ttl: ttl
    }
  end

  defp parse_record(%{type: "NS", name: name, ttl: ttl, data: data}) do
    %DnsRr{name: name, type: NS, data: %DnsRrdataNs{dname: data}, ttl: ttl}
  end

  defp parse_record(%{type: "A", name: name, ttl: ttl, data: data}) do
    case :inet_parse.address(String.to_charlist(data)) do
      {:ok, address} -> %DnsRr{name: name, type: A, data: %DnsRrdataA{ip: address}, ttl: ttl}
      _ -> nil
    end
  end

  defp parse_record(%{type: "AAAA", name: name, ttl: ttl, data: data}) do
    case :inet_parse.address(String.to_charlist(data)) do
      {:ok, address} ->
        %DnsRr{name: name, type: AAAA, data: %DnsRrdataAaaa{ip: address}, ttl: ttl}

      _ ->
        nil
    end
  end

  defp parse_record(%{type: "CNAME", name: name, ttl: ttl, data: data}) do
    %DnsRr{name: name, type: CNAME, data: %DnsRrdataCname{dname: data}, ttl: ttl}
  end

  defp parse_record(_), do: nil

  # __end_of_module__
end
