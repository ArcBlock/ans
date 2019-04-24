defmodule Edns.Zone do
  @moduledoc false

  use TypedStruct
  alias Edns.Zone.Parser

  typedstruct do
    field(:name, String.t())
    field(:record_count, integer())
    field(:authority, [DnsRr.t()])
    field(:records, [DnsRr.t()])
    field(:records_by_name, %{String.t() => [DnsRr.t()]})
  end

  @doc """

  """
  def get_authority(%{__struct__: DnsMessage, questions: []}) do
    {:error, :no_question}
  end

  def get_authority(%{__struct__: DnsMessage, questions: [%{name: query_name} | _]}) do
    get_authority(query_name)
  end

  def get_authority(query_name) do
    case get(query_name) do
      {:ok, zone} -> {:ok, zone.authority}
      _ -> {:error, :authority_not_found}
    end
  end

  @doc """

  """
  def in_zone?(name) do
    case get(name) do
      {:ok, zone} -> is_name_in_zone?(name, zone)
      _ -> false
    end
  end

  @doc false
  defp is_name_in_zone?(name, %{records_by_name: records_by_name} = zone) do
    case Map.has_key?(records_by_name, String.downcase(name)) do
      true ->
        true

      false ->
        case :dns.dname_to_labels(name) do
          [] -> false
          [_] -> false
          [_ | labels] -> is_name_in_zone?(:dns.labels_to_dname(labels), zone)
        end
    end
  end

  @doc """

  """
  def get_records_by_name(name) do
    case get(name) do
      {:ok, %{records_by_name: records_by_name}} ->
        Map.get(records_by_name, String.downcase(name), [])

      _ ->
        []
    end
  end

  @doc """

  """
  def find(name) do
    find(String.downcase(name), get_authority(name))
  end

  @doc """
  """
  def find(_name, {:error, _}), do: {:error, :not_authoritative}
  def find(name, {:ok, authority}), do: find(name, authority)
  def find(_name, []), do: {:error, :not_authoritative}

  def find(name, authority) when is_list(authority) do
    find(name, List.last(authority))
  end

  def find(name, authority) do
    name = String.downcase(name)

    case :dns.dname_to_labels(name) do
      [] -> {:error, :zone_not_found}
      [_ | labels] -> find_do(name, authority, labels)
    end
  end

  @doc false
  defp find_do(name, authority, labels) do
    case get_zone_from_ansc(name) do
      nil ->
        case name == authority.name do
          true -> {:error, :zone_not_found}
          false -> find(:dns.labels_to_dname(labels), authority)
        end

      zone ->
        %{zone | name: name, records: [], records_by_name: :trimmed}
    end
  end

  @doc """

  """
  def get_delegations(name) do
    case get(name) do
      {:ok, %{records: records}} ->
        records
        |> Enum.filter(fn record ->
          record.type == NS and record.data.dname == name
        end)

      _ ->
        []
    end
  end

  @doc false
  defp get([]), do: get("")

  defp get(query_name) do
    query_name = String.downcase(query_name)
    get(query_name, :dns.dname_to_labels(query_name))
  end

  @doc false
  defp get(_query_name, []), do: {:error, :zone_not_found}

  defp get(query_name, [_ | labels]) do
    case get_zone_from_ansc(query_name) do
      nil ->
        case labels do
          [] -> {:error, :zone_not_found}
          _ -> get(:dns.labels_to_dname(labels))
        end

      zone ->
        {:ok, zone}
    end
  end

  @doc false
  defp get_zone_from_ansc(name) do
    name
    |> Ansc.get_domain()
    |> case do
      zone_info when is_bitstring(zone_info) -> build_zone(zone_info)
      _ -> nil
    end
  end

  @doc false
  defp build_zone(zone_info) do
    case Jason.decode(zone_info, keys: :atoms) do
      {:ok, zone_info_decoded} ->
        {name, records} = Parser.parse(zone_info_decoded)

        %__MODULE__{
          name: name,
          record_count: length(records),
          authority: Enum.filter(records, fn record -> SOA == Map.get(record, :type) end),
          records: records,
          records_by_name: Enum.group_by(records, fn i -> Map.get(i, :name) end)
        }

      _ ->
        nil
    end
  end

  # __end_of_module__
end
