defmodule EdnsZoneTest do
  use ExUnit.Case

  alias Edns.Zone

  import Mock

  setup_with_mocks([Edns.Test.Support.MockData.get_domain_mock_data()]) do
    :ok
  end

  test "get authority" do
    assert {:error, :no_question} = Zone.get_authority(%DnsMessage{questions: []})

    assert {:error, :authority_not_found} =
             Zone.get_authority(%DnsMessage{questions: [%DnsQuery{name: "fake_withzonecut.com"}]})

    expect_withzonecut =
      {:ok,
       [
         %DnsRr{
           class: 1,
           data: %DnsRrdataSoa{
             expire: 604_800,
             minimum: 86400,
             mname: "ns1.example.com",
             refresh: 28800,
             retry: 7200,
             rname: "ahu.example.com",
             serial: 2_000_081_501
           },
           name: "withzonecut.com",
           ttl: 86400,
           type: SOA
         }
       ]}

    assert expect_withzonecut == Zone.get_authority("withzonecut.com")
    assert expect_withzonecut == Zone.get_authority("x.zonecut.withzonecut.com")
    assert expect_withzonecut == Zone.get_authority("zonecut.withzonecut.com")
    assert expect_withzonecut == Zone.get_authority("a.withzonecut.com")
  end

  test "in zone" do
    refute Zone.in_zone?("")
    refute Zone.in_zone?("com")
    refute Zone.in_zone?("fake_withzonecut.com")
    assert Zone.in_zone?("withzonecut.com")
    assert Zone.in_zone?("fake.withzonecut.com")
    assert Zone.in_zone?("zonecut.withzonecut.com")
    assert Zone.in_zone?("fake.zonecut.withzonecut.com")
    assert Zone.in_zone?("1.2.3.4.5.6.example.com")
    refute Zone.in_zone?("1.2.3.4.5.6.example_fk.com")
  end

  test "get records by name" do
    assert [] == Zone.get_records_by_name("")
    assert [] == Zone.get_records_by_name("com")
    assert [] == Zone.get_records_by_name("fake.com")
    # expect_withzonecut =
    assert [
             %DnsRr{
               class: 1,
               data: %DnsRrdataSoa{
                 expire: 604_800,
                 minimum: 86400,
                 mname: "ns1.example.com",
                 refresh: 28800,
                 retry: 7200,
                 rname: "ahu.example.com",
                 serial: 2_000_081_501
               },
               name: "withzonecut.com",
               ttl: 86400,
               type: SOA
             },
             %DnsRr{
               class: 1,
               data: %DnsRrdataNs{dname: "ns1.example.com"},
               name: "withzonecut.com",
               ttl: 120,
               type: NS
             },
             %DnsRr{
               class: 1,
               data: %DnsRrdataNs{dname: "ns2.example.com"},
               name: "withzonecut.com",
               ttl: 120,
               type: NS
             }
           ] == Zone.get_records_by_name("withzonecut.com")

    assert [] == Zone.get_records_by_name("fake.withzonecut.com")

    assert [
             %DnsRr{
               class: 1,
               data: %DnsRrdataNs{dname: "ns1.cutwithzonecut.com"},
               name: "zonecut.withzonecut.com",
               ttl: 120,
               type: NS
             },
             %DnsRr{
               class: 1,
               data: %DnsRrdataNs{dname: "ns2.cutwithzonecut.com"},
               name: "zonecut.withzonecut.com",
               ttl: 120,
               type: NS
             }
           ] == Zone.get_records_by_name("zonecut.withzonecut.com")

    assert [
             %DnsRr{
               class: 1,
               data: %DnsRrdataCname{dname: "somewhere.else.net"},
               name: "cnamerecord.zonecut.withzonecut.com",
               ttl: 120,
               type: CNAME
             }
           ] == Zone.get_records_by_name("cnamerecord.zonecut.withzonecut.com")
  end

  test "get delegations" do
    assert [] == Zone.get_delegations("")
    assert [] == Zone.get_delegations("com")
    assert [] == Zone.get_delegations("example.com")

    assert [
             %DnsRr{
               class: 1,
               data: %DnsRrdataNs{dname: "blah.test.com"},
               name: "blah.test.com",
               ttl: 3600,
               type: NS
             }
           ] == Zone.get_delegations("blah.test.com")
  end

  test "find" do
    assert {:error, :not_authoritative} == Zone.find("")
    assert {:error, :not_authoritative} == Zone.find("com")
    assert {:error, :not_authoritative} == Zone.find("withzonecut_fake.com")

    expect_zone = %Edns.Zone{
      authority: [
        %DnsRr{
          class: 1,
          data: %DnsRrdataSoa{
            expire: 604_800,
            minimum: 86400,
            mname: "ns1.example.com",
            refresh: 28800,
            retry: 7200,
            rname: "ahu.example.com",
            serial: 2_000_081_501
          },
          name: "withzonecut.com",
          ttl: 86400,
          type: SOA
        }
      ],
      name: "withzonecut.com",
      record_count: 6,
      records: [],
      records_by_name: :trimmed
    }

    assert expect_zone == Zone.find("withzonecut.com")
    assert expect_zone == Zone.find("zonecur.withzonecut.com")
    assert expect_zone == Zone.find("a.a.a.acnamerecord.withzonecut.com")
  end

  # __end_of_module__
end
