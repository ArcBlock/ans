defmodule Edns.Type do
  @moduledoc false

  @doc """

  """
  def encode(A), do: 1
  def encode(NS), do: 2
  def encode(CNAME), do: 5
  def encode(SOA), do: 6
  def encode(AAAA), do: 28
  def encode(ANY), do: 255

  @doc """

  """
  def decode(1), do: A
  def decode(2), do: NS
  def decode(5), do: CNAME
  def decode(6), do: SOA
  def decode(28), do: AAAA
  def decode(255), do: ANY

  # __end_of_module__
end
