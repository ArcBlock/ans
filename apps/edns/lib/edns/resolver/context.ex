defmodule Edns.Resolver.Context do
  @moduledoc """

  """

  use TypedStruct

  typedstruct do
    field(:message, DnsMessage.t())
    field(:query_name, String.t())
    field(:query_type, atom())
    field(:zone, {:error, :not_authoritative} | {:ok, Edns.Zone.t()})
  end

  @doc """

  """
  def build(msg, query_name, query_type, zone) do
    %__MODULE__{message: msg, query_name: query_name, query_type: query_type, zone: zone}
  end

  # __end_of_module__
end
