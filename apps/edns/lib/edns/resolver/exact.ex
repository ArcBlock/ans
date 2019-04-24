defmodule Edns.Resolver.Exact do
  @moduledoc """

  """

  @dns_type_any 255

  @dns_rcode_noerror 0
  @dns_rcode_servfail 2

  alias Edns.Resolver.Util
  alias Edns.Resolver.Zone, as: ResolverZone
  alias Edns.Zone

  @doc """

  """
  def resolve(context, matched_rr, cname_chain) do
    case Util.cname_rr_list(matched_rr) do
      [] -> resolve_exact(context, matched_rr, cname_chain)
      cname_rr_list -> resolve_exact_cname(context, cname_rr_list, cname_chain)
    end
  end

  #
  @doc false
  defp resolve_exact(
         %{query_type: query_type, message: msg, zone: zone} = context,
         matched_rr,
         cname_chain
       ) do
    query_type
    |> case do
      @dns_type_any -> matched_rr
      _ -> Util.rr_list_by_type(matched_rr, query_type)
    end
    |> case do
      [] -> matched_rr
      type_matched_rr -> type_matched_rr
    end
    |> case do
      [] ->
        %{msg | aa: true, authority: zone.authority}

      type_matched_rr ->
        authority_rr_list = Util.soa_rr_list(matched_rr)
        resolve_exact_type(context, type_matched_rr, authority_rr_list, cname_chain)
    end
  end

  @doc false
  defp resolve_exact_type(%{query_type: NS} = context, type_matched_rr, [], cname_chain) do
    %{name: type_matched_rr_name} = List.last(type_matched_rr)

    Util.restart_delegated(
      Zone.in_zone?(type_matched_rr_name),
      %{context | query_type: A, query_name: type_matched_rr_name},
      cname_chain
    )
  end

  defp resolve_exact_type(%{query_type: NS, message: msg}, type_matched_rr, _, _cname_chain) do
    %{msg | aa: true, rc: @dns_rcode_noerror, answers: msg.answers ++ type_matched_rr}
  end

  defp resolve_exact_type(
         %{message: msg, query_name: query_name} = context,
         type_matched_rr,
         _authority_rr_list,
         cname_chain
       ) do
    type_matched_rr
    |> List.last()
    |> Map.get(:name)
    |> Zone.get_delegations()
    |> case do
      [] ->
        %{msg | aa: true, rc: @dns_rcode_noerror, answers: msg.answers ++ type_matched_rr}

      ns_rr ->
        %{name: ns_r_name} = List.last(ns_rr)

        case Zone.get_authority(query_name) do
          {:ok, [%{name: soa_r_name} | _]} when soa_r_name == ns_r_name ->
            %{msg | aa: true, rc: @dns_rcode_noerror, answers: msg.answers ++ type_matched_rr}

          _ ->
            resolve_exact_type_do(context, type_matched_rr, ns_rr, cname_chain)
        end
    end
  end

  @doc false
  defp resolve_exact_type_do(%{message: msg} = context, type_matched_rr, ns_rr, cname_chain) do
    %{name: type_matched_rr_name} = List.last(type_matched_rr)
    %{name: ns_r_name} = List.last(ns_rr)

    if type_matched_rr_name == ns_r_name do
      %{msg | aa: false, rc: @dns_rcode_noerror, authority: msg.authority ++ ns_rr}
    else
      if Util.check_if_parent(ns_r_name, type_matched_rr_name) do
        new_context = %{context | query_name: ns_r_name}
        Util.restart_delegated(Zone.in_zone?(ns_r_name), new_context, cname_chain)
      else
        %{msg | aa: true, rc: @dns_rcode_noerror, answers: msg.answers ++ type_matched_rr}
      end
    end
  end

  #
  @doc false
  defp resolve_exact_cname(%{query_type: CNAME, message: msg}, cname_rr_list, _) do
    %{msg | aa: true, answers: msg.answers ++ cname_rr_list}
  end

  defp resolve_exact_cname(%{message: msg} = context, cname_rr_list, cname_chain) do
    if Enum.member?(cname_chain, List.last(cname_rr_list)) do
      %{msg | aa: true, rc: @dns_rcode_servfail}
    else
      resolve_exact_cname_do(context, cname_rr_list, cname_chain)
    end
  end

  @doc false
  defp resolve_exact_cname_do(%{message: msg, zone: zone} = context, cname_rr_list, cname_chain) do
    %{data: %{dname: cname_name}} = List.last(cname_rr_list)
    new_msg = %{msg | aa: true, answers: msg.answers ++ cname_rr_list}
    new_cname_chain = cname_rr_list ++ cname_chain

    if Zone.in_zone?(cname_name) and Util.check_if_parent(zone.name, cname_name) do
      ResolverZone.resolve(%{context | message: new_msg, query_name: cname_name}, new_cname_chain)
    else
      new_msg
    end
  end

  # __end_of_module__
end
