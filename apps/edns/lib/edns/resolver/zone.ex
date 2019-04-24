defmodule Edns.Resolver.Zone do
  @moduledoc """

  """

  @dns_rcode_nxdomain 3

  alias Edns.Resolver.Exact
  alias Edns.Zone

  @doc """

  """
  def resolve(%{query_name: name, zone: zone, message: msg} = context, cname_chain) do
    case Zone.get_records_by_name(name) do
      [] -> %{msg | aa: true, rc: @dns_rcode_nxdomain, authority: zone.authority}
      matched_rr -> Exact.resolve(context, matched_rr, cname_chain)
    end
  end

  # __end_of_module__
end
