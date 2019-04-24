defmodule Edns do
  @moduledoc """
  Documentation for Edns.
  """

  require Logger

  @dns_rcode_servfail 2

  @doc """

  """
  def decode_message(bin) do
    bin
    |> :dns.decode_message()
    |> Dnsm.from_record()
    |> decode_rr_type()
  catch
    _, e ->
      Logger.error("Error decoding, message: #{inspect(bin)}, error: #{inspect(e)}")
      {:formeer, e, bin}
  end

  @doc false
  defp decode_rr_type(%{questions: questions} = message) do
    %{message | questions: Enum.map(questions, &decode_rr_type_do/1)}
  end

  @doc false
  defp decode_rr_type_do(%{type: type} = r) do
    %{r | type: Edns.Type.decode(type)}
  end

  @doc """

  """
  def encode_message(message) do
    message
    |> encode_rr_type()
    |> Dnsm.to_record()
    |> :dns.encode_message()
  catch
    _, e ->
      Logger.error("Error encoding, message: #{inspect(message)}, error: #{inspect(e)}")
      encode_message(build_error_message(message))
  end

  @doc """

  """
  def encode_message(message, options) do
    message
    |> encode_rr_type()
    |> Dnsm.to_record()
    |> :dns.encode_message(options)
  catch
    _, e ->
      Logger.error("Error encoding, message: #{inspect(message)}, error: #{inspect(e)}")
      {false, encode_message(build_error_message(message))}
  end

  @doc false
  defp build_error_message(%{__struct__: DnsMessage} = message) do
    build_error_message(message, @dns_rcode_servfail)
  end

  defp build_error_message({_, message}) do
    build_error_message(message, @dns_rcode_servfail)
  end

  defp build_error_message(message, rcode) do
    %{
      message
      | anc: 0,
        auc: 0,
        qr: true,
        aa: true,
        rc: rcode,
        answers: [],
        authority: [],
        additional: []
    }
  end

  @doc false
  defp encode_rr_type(%{answers: answers, authority: authority, questions: questions} = message) do
    %{
      message
      | answers: Enum.map(answers, &encode_rr_type_do/1),
        authority: Enum.map(authority, &encode_rr_type_do/1),
        questions: Enum.map(questions, &encode_rr_type_do/1),
        additional: []
    }
  end

  defp encode_rr_type_do(%{type: type} = r) do
    %{r | type: Edns.Type.encode(type)}
  end

  # __end_of_module__
end
