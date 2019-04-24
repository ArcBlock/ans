defmodule Edns.Resolver do
  @moduledoc false

  @dns_type_rrsig 46
  @dns_rcode_refused 5

  alias Edns.Resolver.{Context, Zone}

  @doc """

  """
  def resolve(%{questions: [%{type: @dns_type_rrsig} | _]} = message, _, _) do
    %{message | ra: false, ad: false, cd: false, rc: @dns_rcode_refused}
  end

  def resolve(%{questions: [%{type: type, name: name} | _]} = message, authority, host) do
    zone = Edns.Zone.find(name, List.last(authority))

    %{message | ra: false, ad: false, cd: false}
    |> Context.build(name, type, zone)
    |> Zone.resolve([])
    |> rewrite_soa_ttl()
    |> additional_processing(host, zone)
    |> sort_answers()
  end

  def resolve(message, _, _), do: message

  @doc false
  defp rewrite_soa_ttl(message) do
    rewrite_soa_ttl(message, message.authority, [])
  end

  defp rewrite_soa_ttl(message, [], new_authority) do
    %{message | authority: new_authority}
  end

  defp rewrite_soa_ttl(message, [r | rest], new_authority) do
    rewrite_soa_ttl(message, rest, new_authority ++ [minimum_soa_ttl(r, r.data)])
  end

  @doc false
  defp minimum_soa_ttl(r, %{__struct__: DnsRrdataSoa} = data) do
    %{r | ttl: min(data.minimum, r.ttl)}
  end

  defp minimum_soa_ttl(r, _), do: r

  @doc false
  defp additional_processing(message, _host, _zone) do
    message
  end

  @doc false
  defp sort_answers(message) do
    message
  end

  # __end_of_module__
end
