defmodule Edns.Test.Support.MockData do
  @moduledoc false

  @doc """

  """
  def get_domain_mock_data do
    {Ansc, [],
     [
       get_domain: fn
         "withzonecut.com" ->
           """
           {
           "name": "withzonecut.com",
           "records": [
           {
               "name": "withzonecut.com",
               "type": "SOA",
               "data": {
                   "mname": "ns1.example.com",
                   "rname": "ahu.example.com",
                   "serial": 2000081501,
                   "refresh": 28800,
                   "retry": 7200,
                   "expire": 604800,
                   "minimum": 86400
               },
               "ttl": 86400
           },
           {
               "name": "withzonecut.com",
               "type": "NS",
               "ttl": 120,
               "data": "ns1.example.com"
           },
           {
               "name": "withzonecut.com",
               "type": "NS",
               "ttl": 120,
               "data": "ns2.example.com"
           },
           {
               "name": "zonecut.withzonecut.com",
               "type": "NS",
               "ttl": 120,
               "data": "ns1.cutwithzonecut.com"
           },
           {
               "name": "zonecut.withzonecut.com",
               "type": "NS",
               "ttl": 120,
               "data": "ns2.cutwithzonecut.com"
           },
           {
               "name": "cnamerecord.zonecut.withzonecut.com",
               "type": "CNAME",
               "ttl": 120,
               "data": "somewhere.else.net"
           }
           ]
           }
           """

         "example.com" ->
           """
               {
                   "name": "example.com",
                   "records": [
                       {
                           "name": "example.com",
                           "type": "SOA",
                           "data": {
                               "mname": "ns1.example.com",
                               "rname": "ahu.example.com",
                               "serial": 2000081501,
                               "refresh": 28800,
                               "retry": 7200,
                               "expire": 604800,
                               "minimum": 86400
                           },
                           "ttl": 86400
                       },
                       {
                           "name": "example.com",
                           "type": "NS",
                           "ttl": 120,
                           "data": "ns1.example.com"
                       },
                       {
                           "name": "example.com",
                           "type": "NS",
                           "ttl": 120,
                           "data": "ns2.example.com"
                       },
                       {
                           "name": "rns.example.com",
                           "type": "A",
                           "ttl": 120,
                           "data": "1.2.3.4"
                       },
                       {
                           "name": "ns1.example.com",
                           "type": "A",
                           "ttl": 120,
                           "data": "192.168.1.1"
                       },
                       {
                           "name": "ns1.example.com",
                           "type": "AAAA",
                           "ttl": 120,
                           "data": "2001:0db8:85a3:0000:0000:8a2e:0370:7334"
                       },
                       {
                           "name": "ns2.example.com",
                           "type": "A",
                           "ttl": 120,
                           "data": "192.168.1.2"
                       },
                       {
                           "name": "double.example.com",
                           "type": "A",
                           "ttl": 120,
                           "data": "192.168.5.1"
                       },
                       {
                           "name": "localhost.example.com",
                           "type": "A",
                           "ttl": 120,
                           "data": "127.0.0.1"
                       },
                       {
                           "name": "www.example.com",
                           "type": "CNAME",
                           "ttl": 120,
                           "data": "outpost.example.com"
                       },
                       {
                           "name": "unauth.example.com",
                           "type": "CNAME",
                           "ttl": 120,
                           "data": "no-idea.example.org"
                       },
                       {
                           "name": "dsdelegation.example.com",
                           "type": "NS",
                           "ttl": 120,
                           "data": "ns.example.com"
                       },
                       {
                           "name": "nxd.example.com",
                           "type": "CNAME",
                           "ttl": 120,
                           "data": "nxdomain.example.com"
                       },
                       {
                           "name": "smtp-servers.example.com",
                           "type": "A",
                           "ttl": 120,
                           "data": "192.168.0.2"
                       },
                       {
                           "name": "smtp-servers.example.com",
                           "type": "A",
                           "ttl": 120,
                           "data": "192.168.0.3"
                       },
                       {
                           "name": "smtp-servers.example.com",
                           "type": "A",
                           "ttl": 120,
                           "data": "192.168.0.4"
                       },
                       {
                           "name": "outpost.example.com",
                           "type": "A",
                           "ttl": 120,
                           "data": "192.168.2.1"
                       },
                       {
                           "name": "start.example.com",
                           "type": "CNAME",
                           "ttl": 120,
                           "data": "x.y.z.w1.example.com"
                       },
                       {
                           "name": "*.w1.example.com",
                           "type": "CNAME",
                           "ttl": 120,
                           "data": "x.y.z.w2.example.com"
                       },
                       {
                           "name": "*.w2.example.com",
                           "type": "CNAME",
                           "ttl": 120,
                           "data": "x.y.z.w3.example.com"
                       },
                       {
                           "name": "*.w3.example.com",
                           "type": "CNAME",
                           "ttl": 120,
                           "data": "x.y.z.w4.example.com"
                       },
                       {
                           "name": "*.w4.example.com",
                           "type": "CNAME",
                           "ttl": 120,
                           "data": "x.y.z.w5.example.com"
                       },
                       {
                           "name": "*.w5.example.com",
                           "type": "A",
                           "ttl": 120,
                           "data": "1.2.3.5"
                       },
                       {
                           "name": "start1.example.com",
                           "type": "CNAME",
                           "ttl": 120,
                           "data": "start2.example.com"
                       },
                       {
                           "name": "start2.example.com",
                           "type": "CNAME",
                           "ttl": 120,
                           "data": "start3.example.com"
                       },
                       {
                           "name": "start3.example.com",
                           "type": "CNAME",
                           "ttl": 120,
                           "data": "start4.example.com"
                       },
                       {
                           "name": "start4.example.com",
                           "type": "A",
                           "ttl": 120,
                           "data": "192.168.2.2"
                       },
                       {
                           "name": "loop1.example.com",
                           "type": "CNAME",
                           "ttl": 120,
                           "data": "loop2.example.com"
                       },
                       {
                           "name": "loop2.example.com",
                           "type": "CNAME",
                           "ttl": 120,
                           "data": "loop3.example.com"
                       },
                       {
                           "name": "loop3.example.com",
                           "type": "CNAME",
                           "ttl": 120,
                           "data": "loop1.example.com"
                       },
                       {
                           "name": "external.example.com",
                           "type": "CNAME",
                           "ttl": 120,
                           "data": "somewhere.else.net"
                       },
                       {
                           "name": "semi-external.example.com",
                           "type": "CNAME",
                           "ttl": 120,
                           "data": "bla.something.wtest.com"
                       },
                       {
                           "name": "server1.example.com",
                           "type": "CNAME",
                           "ttl": 120,
                           "data": "server1.france.example.com"
                       },
                       {
                           "name": "france.example.com",
                           "type": "NS",
                           "ttl": 120,
                           "data": "ns1.otherprovider.net"
                       },
                       {
                           "name": "france.example.com",
                           "type": "NS",
                           "ttl": 120,
                           "data": "ns2.otherprovider.net"
                       },
                       {
                           "name": "smtp1.example.com",
                           "type": "CNAME",
                           "ttl": 120,
                           "data": "outpost.example.com"
                       },
                       {
                           "name": "host.*.sub.example.com",
                           "type": "A",
                           "ttl": 120,
                           "data": "192.168.6.1"
                       },
                       {
                           "name": "ipv6.example.com",
                           "type": "AAAA",
                           "ttl": 120,
                           "data": "2001:6A8:0:1:210:4BFF:FE4B:4C61"
                       },
                       {
                           "name": "toomuchinfo-a.example.com",
                           "type": "A",
                           "ttl": 120,
                           "data": "192.168.99.1"
                       },

                       {
                           "name": "toomuchinfo-a.example.com",
                           "type": "A",
                           "ttl": 120,
                           "data": "192.168.99.2"
                       },
                       {
                           "name": "toomuchinfo-b.example.com",
                           "type": "A",
                           "ttl": 120,
                           "data": "192.168.99.59"
                       },
                       {
                           "name": "toomuchinfo-b.example.com",
                           "type": "A",
                           "ttl": 120,
                           "data": "192.168.99.58"
                       }
                   ]
               }
           """

         "test.com" ->
           """
               {
                   "name": "test.com",
                   "records": [
                       {
                           "name": "test.com",
                           "type": "SOA",
                           "data": {
                               "mname": "ns1.test.com",
                               "rname": "ahu.example.com",
                               "serial": 2005092501,
                               "refresh": 28800,
                               "retry": 7200,
                               "expire": 604800,
                               "minimum": 86400
                           },
                           "ttl": 3600
                       },
                       {
                           "name": "test.com",
                           "type": "NS",
                           "ttl": 3600,
                           "data": "ns1.test.com"
                       },
                       {
                           "name": "test.com",
                           "type": "NS",
                           "ttl": 3600,
                           "data": "ns2.test.com"
                       },
                       {
                           "name": "test.com",
                           "type": "NS",
                           "ttl": 3600,
                           "data": "test.com"
                       },
                       {
                           "name": "test.com",
                           "type": "A",
                           "ttl": 3600,
                           "data": "192.168.6.11"
                       },
                       {
                           "name": "ns1.test.com",
                           "type": "A",
                           "ttl": 3600,
                           "data": "1.1.1.1"
                       },
                       {
                           "name": "ns2.test.com",
                           "type": "A",
                           "ttl": 3600,
                           "data": "2.2.2.2"
                       },
                       {
                           "name": "toroot.test.com",
                           "type": "CNAME",
                           "ttl": 3600,
                           "data": ""
                       },
                       {
                           "name": "www.test.com",
                           "type": "CNAME",
                           "ttl": 3600,
                           "data": "server1.test.com"
                       },
                       {
                           "name": "server1.test.com",
                           "type": "A",
                           "ttl": 3600,
                           "data": "1.2.3.4"
                       },
                       {
                           "name": "*.test.test.com",
                           "type": "CNAME",
                           "ttl": 3600,
                           "data": "server1.test.com"
                       },
                       {
                           "name": "www.test.test.com",
                           "type": "A",
                           "ttl": 3600,
                           "data": "4.3.2.1"
                       },
                       {
                           "name": "sub.test.test.com",
                           "type": "NS",
                           "ttl": 3600,
                           "data": "ns-test.example.net.test.com"
                       },
                       {
                           "name": "counter.test.com",
                           "type": "A",
                           "ttl": 3600,
                           "data": "1.1.1.5"
                       },
                       {
                           "name": "counter.test.com",
                           "type": "A",
                           "ttl": 3600,
                           "data": "1.1.1.5"
                       },
                       {
                           "name": "_ldap._tcp.dc.test.com",
                           "type": "SRV",
                           "ttl": 3600,
                           "data": {
                               "priority": 0,
                               "weight": 100,
                               "port": 389,
                               "target": "server2.example.net"
                           }
                       },
                       {
                           "name": "_double._tcp.dc.test.com",
                           "type": "SRV",
                           "ttl": 3600,
                           "data": {
                               "priority": 0,
                               "weight": 100,
                               "port": 389,
                               "target": "server1.test.com"
                           }
                       },
                       {
                           "name": "_double._tcp.dc.test.com",
                           "type": "SRV",
                           "ttl": 3600,
                           "data": {
                               "priority": 1,
                               "weight": 100,
                               "port": 389,
                               "target": "server1.test.com"
                           }
                       },
                       {
                           "name": "_root._tcp.dc.test.com",
                           "type": "SRV",
                           "ttl": 3600,
                           "data": {
                               "priority": 0,
                               "weight": 0,
                               "port": 0,
                               "target": ""
                           }
                       },
                       {
                           "name": "blah.test.com",
                           "type": "NS",
                           "ttl": 3600,
                           "data": "blah.test.com"
                       },
                       {
                           "name": "blah.test.com",
                           "type": "A",
                           "ttl": 3600,
                           "data": "192.168.6.1"
                       },
                       {
                           "name": "within-server.test.com",
                           "type": "CNAME",
                           "ttl": 3600,
                           "data": "outpost.example.com"
                       },
                       {
                           "name": "b.c.test.com",
                           "type": "A",
                           "ttl": 3600,
                           "data": "5.6.7.8"
                       },
                       {
                           "name": "*.a.b.c.test.com",
                           "type": "A",
                           "ttl": 3600,
                           "data": "8.7.6.5"
                       }
                   ]
               }
           """

         "wtest.com" ->
           """
           {
           "name": "wtest.com",
           "records": [
           {
               "name": "wtest.com",
               "type": "SOA",
               "data": {
                   "mname": "ns1.wtest.com",
                   "rname": "ahu.example.com",
                   "serial": 2005092501,
                   "refresh": 28800,
                   "retry": 7200,
                   "expire": 604800,
                   "minimum": 86400
               },
               "ttl": 3600
           },
           {
               "name": "wtest.com",
               "type": "NS",
               "ttl": 3600,
               "data": ""
           },
           {
               "name": "wtest.com",
               "type": "NS",
               "ttl": 3600,
               "data": "ns1.wtest.com"
           },
           {
               "name": "wtest.com",
               "type": "A",
               "ttl": 3600,
               "data": "9.9.9.9"
           },
           {
               "name": "ns1.wtest.com",
               "type": "A",
               "ttl": 3600,
               "data": "2.3.4.5"
           },
           {
               "name": "ns2.wtest.com",
               "type": "A",
               "ttl": 3600,
               "data": "5.6.7.8"
           },
           {
               "name": "*.wtest.com",
               "type": "CNAME",
               "ttl": 3600,
               "data": "server.wtest.com"
           },
           {
               "name": "server1.wtest.com",
               "type": "A",
               "ttl": 3600,
               "data": "1.2.3.4"
           },
           {
               "name": "*.something.wtest.com",
               "type": "A",
               "ttl": 3600,
               "data": "4.3.2.1"
           },
           {
               "name": "*.a.b.c.d.e.wtest.com",
               "type": "A",
               "ttl": 3600,
               "data": "6.7.8.9"
           },
           {
               "name": "a.something.wtest.com",
               "type": "A",
               "ttl": 3600,
               "data": "10.11.12.13"
           },
           {
               "name": "proxy.cover.wtest.com",
               "type": "A",
               "ttl": 3600,
               "data": "1.2.3.4"
           },
           {
               "name": "*.cover.wtest.com",
               "type": "CNAME",
               "ttl": 3600,
               "data": "proxy.cover.wtest.com"
           }
           ]
           }
           """

         "minimal.com" ->
           """
             {
             "name": "minimal.com",
             "records": [
              {
                  "name": "minimal.com",
                  "type": "SOA",
                  "data": {
                      "mname": "ns1.example.com",
                      "rname": "ahu.example.com",
                      "serial": 2000081501,
                      "refresh": 28800,
                      "retry": 7200,
                      "expire": 604800,
                      "minimum": 86400
                  },
                  "ttl": 120
              },
              {
                  "name": "minimal.com",
                  "type": "NS",
                  "ttl": 120,
                  "data": "ns1.example.com"
              },
              {
                  "name": "minimal.com",
                  "type": "NS",
                  "ttl": 120,
                  "data": "ns2.example.com"
              }
             ]
             }
           """

         _ ->
           nil
       end
     ]}
  end

  # __end_of_module__
end
