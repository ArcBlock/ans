# Ans

`ans` is short for `arcblock name service` and will support several feature:

- domain management
- dns request resolve

In fact, `ans` including two main parts:

- edns

  it will receive dns client request, and resolve the dns request then return to client.

- ansc

  `ans` will store the domain zone information on the blockchain using forge framework, and the domain zone information is the source for `dns server`.

## edns

`edns` is a typical UDP server and it will implement a subset of DNS protocol.

## ansc

`ansc` is short for `ans chain`, it including several operations, like:

- register domain
- update domain
- exchange domain

On the whole, someone could register domain through `ancs`, and `ancs` will store the domain zone information on the blockchain, then `edns` will resolve the dns UDP request depend on the domain zone information from the blockchain.
