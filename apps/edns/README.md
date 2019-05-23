# Edns

edns is a UDP server and it implement a subset of DNS protocol. edns including several important parts:

- UDP server
- zone information parsing
- dns request resolver

## UDP server

UDP server using `GenServer` OTP behavior which supervised by supervisor tree and listening the UDP port. When client send request to the server with dns protocol, the server will receive the request and will spawn one process which will take one worker process to resolve the dns request.

```elixir
  @doc false
  defp handle_request(socket, host, port, bin) do
    spawn(fn ->
      :poolboy.transaction(
        worker_pool_name(),
        fn pid -> UdpWorker.handle_request(pid, socket, host, port, bin) end
      )
    end)
  end
```

The operation just for performance.

## zone information parsing

zone information parsing also including two parts:

- fetch the zone information

  fetch zone information from the blockchain through `ansc` depends on appropriate domain domain.

  ```elixir
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
  ```

  the `get` operation will use the domain splited by `.` (implemented by `:dns.dname_to_labels/1` and `:dns.labels_to_dname/1` functions) recursively.

- build zone struct

  build zone struct which will be used for resolver through zone information parser, and the parser will parse the external data into `dns resouce record` data. And the `resource record` type including:

  - SOA
  - A
  - AAAA
  - CNAME
  - SRV

## dns request resolver

resolver will resolve the dns request and find appropriate response depends on the dns request questions.

