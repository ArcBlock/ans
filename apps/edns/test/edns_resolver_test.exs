defmodule EdnsResolverTest do
  use ExUnit.Case

  alias Edns.{Resolver, Zone}

  import Mock

  @dns_type_a A
  @dns_type_ns NS
  @dns_type_cname CNAME
  # @dns_type_any ANY
  @host "127.0.0.1"

  setup_with_mocks([Edns.Test.Support.MockData.get_domain_mock_data()]) do
    :ok
  end

  test "resolve dns type is rrsig" do
    message = %DnsMessage{questions: [%DnsQuery{type: 46}]}
    new_message = Resolver.resolve(message, nil, nil)
    assert false == new_message.ra
    assert false == new_message.ad
    assert false == new_message.cd
    assert 5 == new_message.rc
  end

  test "resolve dns, questions is empty" do
    Resolver.resolve(%DnsMessage{}, nil, nil)
  end

  test "resolve best: nxdomain 1" do
    name = "start3sssa.a.a.a.a.start1.example.com"
    message = build_query_message(@dns_type_a, name)
    {:ok, authority} = Zone.get_authority(name)
    assert authority == Resolver.resolve(message, authority, @host).authority
  end

  test "resolve best: nxdomain 2, but has ns rr list" do
    name = "start3sssa.a.a.a.a.example.com"
    message = build_query_message(@dns_type_a, name)
    {:ok, authority} = Zone.get_authority(name)
    assert authority == Resolver.resolve(message, authority, @host).authority
  end

  # "name": "withzonecut.com",
  # "records": [
  #     {
  #         "name": "withzonecut.com",
  #         "type": "SOA",
  #         "data": {
  #             "mname": "ns1.example.com",
  #             "rname": "ahu.example.com",
  #             "serial": 2000081501,
  #             "refresh": 28800,
  #             "retry": 7200,
  #             "expire": 604800,
  #             "minimum": 86400
  #         },
  #         "ttl": 86400
  #     },
  #     {
  #         "name": "withzonecut.com",
  #         "type": "NS",
  #         "ttl": 120,
  #         "data": "ns1.example.com"
  #     },
  #     {
  #         "name": "withzonecut.com",
  #         "type": "NS",
  #         "ttl": 120,
  #         "data": "ns2.example.com"
  #     },
  test "resolve exact 1" do
    name = "withzonecut.com"
    message = build_query_message(@dns_type_a, name)
    {:ok, authority} = Zone.get_authority(name)

    assert [
             %DnsRr{name: "withzonecut.com", type: SOA},
             %DnsRr{data: %DnsRrdataNs{dname: "ns1.example.com"}, type: NS},
             %DnsRr{data: %DnsRrdataNs{dname: "ns2.example.com"}, type: NS}
           ] = Resolver.resolve(message, authority, @host).answers
  end

  # {
  #     "name": "blah.test.com",
  #     "type": "NS",
  #     "ttl": 3600,
  #     "data": "blah.test.com"
  # },
  # {
  #     "name": "blah.test.com",
  #     "type": "A",
  #     "ttl": 3600,
  #     "data": "192.168.6.1"
  # },
  test "resolve exact 2" do
    name = "blah.test.com"
    message = build_query_message(@dns_type_a, name)
    {:ok, authority} = Zone.get_authority(name)
    assert [] == Resolver.resolve(message, authority, @host).answers
  end

  # "name": "test.com",
  # "records": [
  #     {
  #         "name": "test.com",
  #         "type": "SOA",
  #         "data": {
  #             "mname": "ns1.test.com",
  #             "rname": "ahu.example.com",
  #             "serial": 2005092501,
  #             "refresh": 28800,
  #             "retry": 7200,
  #             "expire": 604800,
  #             "minimum": 86400
  #         },
  #         "ttl": 3600
  #     },
  #     {
  #         "name": "test.com",
  #         "type": "NS",
  #         "ttl": 3600,
  #         "data": "ns1.test.com"
  #     },
  #     {
  #         "name": "test.com",
  #         "type": "NS",
  #         "ttl": 3600,
  #         "data": "ns2.test.com"
  #     },
  #     {
  #         "name": "test.com",
  #         "type": "NS",
  #         "ttl": 3600,
  #         "data": "test.com"
  #     },
  #     {
  #         "name": "test.com",
  #         "type": "A",
  #         "ttl": 3600,
  #         "data": "192.168.6.11"
  #     },
  test "resolve exact 3" do
    name = "test.com"
    message = build_query_message(@dns_type_ns, name)
    {:ok, authority} = Zone.get_authority(name)

    assert [
             %DnsRr{data: %DnsRrdataNs{dname: "ns1.test.com"}, type: NS},
             %DnsRr{data: %DnsRrdataNs{dname: "ns2.test.com"}, type: NS},
             %DnsRr{data: %DnsRrdataNs{dname: "test.com"}, type: NS}
           ] = Resolver.resolve(message, authority, @host).answers
  end

  test "resolve exact 4" do
    name = "test.com"
    message = build_query_message(@dns_type_a, name)
    {:ok, authority} = Zone.get_authority(name)

    assert [
             %DnsRr{data: %DnsRrdataA{ip: {192, 168, 6, 11}}, name: "test.com", type: A}
           ] = Resolver.resolve(message, authority, @host).answers
  end

  # {
  #     "name": "sub.test.test.com",
  #     "type": "NS",
  #     "ttl": 3600,
  #     "data": "ns-test.example.net.test.com"
  # },
  test "resolve exact 5" do
    name = "sub.test.test.com"
    message = build_query_message(@dns_type_ns, name)
    {:ok, authority} = Zone.get_authority(name)

    assert [%DnsRr{data: %DnsRrdataNs{dname: "ns-test.example.net.test.com"}, type: NS}] =
             Resolver.resolve(message, authority, @host).answers
  end

  # {
  #     "name": "start1.example.com",
  #     "type": "CNAME",
  #     "ttl": 120,
  #     "data": "start2.example.com"
  # },
  # {
  #     "name": "start2.example.com",
  #     "type": "CNAME",
  #     "ttl": 120,
  #     "data": "start3.example.com"
  # },
  # {
  #     "name": "start3.example.com",
  #     "type": "CNAME",
  #     "ttl": 120,
  #     "data": "start4.example.com"
  # },
  # {
  #     "name": "start4.example.com",
  #     "type": "A",
  #     "ttl": 120,
  #     "data": "192.168.2.2"
  # },
  test "resolve exact cname 1" do
    name = "start3.example.com"
    message = build_query_message(@dns_type_cname, name)
    {:ok, authority} = Zone.get_authority(name)

    assert [
             %DnsRr{
               data: %DnsRrdataCname{dname: "start4.example.com"},
               name: "start3.example.com",
               type: CNAME
             }
           ] = Resolver.resolve(message, authority, @host).answers
  end

  test "resolve exact cname 2" do
    name = "start3.example.com"
    message = build_query_message(@dns_type_a, name)
    {:ok, authority} = Zone.get_authority(name)

    assert [
             %DnsRr{
               data: %DnsRrdataCname{dname: "start4.example.com"},
               name: "start3.example.com",
               type: CNAME
             },
             %DnsRr{
               data: %DnsRrdataA{ip: {192, 168, 2, 2}},
               name: "start4.example.com",
               type: A
             }
           ] = Resolver.resolve(message, authority, @host).answers
  end

  # {
  #     "name": "loop1.example.com",
  #     "type": "CNAME",
  #     "ttl": 120,
  #     "data": "loop2.example.com"
  # },
  # {
  #     "name": "loop2.example.com",
  #     "type": "CNAME",
  #     "ttl": 120,
  #     "data": "loop3.example.com"
  # },
  # {
  #     "name": "loop3.example.com",
  #     "type": "CNAME",
  #     "ttl": 120,
  #     "data": "loop1.example.com"
  # },

  test "resolve exact cname loop" do
    name = "loop1.example.com"
    message = build_query_message(@dns_type_a, name)
    {:ok, authority} = Zone.get_authority(name)

    assert [
             %DnsRr{
               data: %DnsRrdataCname{dname: "loop2.example.com"},
               name: "loop1.example.com",
               type: CNAME
             },
             %DnsRr{
               data: %DnsRrdataCname{dname: "loop3.example.com"},
               name: "loop2.example.com",
               type: CNAME
             },
             %DnsRr{
               data: %DnsRrdataCname{dname: "loop1.example.com"},
               name: "loop3.example.com",
               type: CNAME
             }
           ] = Resolver.resolve(message, authority, @host).answers
  end

  defp build_query_message(type, name) do
    %DnsMessage{questions: [%DnsQuery{type: type, name: name}]}
  end

  # __end_of_module__
end
