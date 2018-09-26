# setup-dmvpn

This guide explains how to set up a Dynamic Multipoint VPN using `setup-dmvpn`.

## Certificate Authority

Install the Certificate Authority (CA) tool on a secure host:

<pre>apk add dmvpn-ca
</pre>

Configure the CA by editing `/etc/dmvpn-ca.conf`. In this example, the following
configuration is used:

<pre>hub:
  hosts:
  - hubs.example.com
  subnets:
  - '10.0.0.0/8'
  - '172.18.0.0/16'
  - 'fd00::/32'

crl:
  dist-point: 'http://crl.example.com/dmvpn-ca.crl'
  lifetime: 1800
  renewal: 1200
</pre>

The `hosts` attribute specifies the IPv4 addresses of the hubs or DNS name(s)
resolving to those. In this example, it is assumed that resolution of
`hubs.example.com` yields an A record for each hub.

The `subnets` attribute is a list of subnets used in the VPN. This should
include the address ranges of all sites and the GRE tunnel addresses. In this
example, the following IP address scheme is used:

The `crl` object should be left out unless the CRL distribution point will be
configured.

<table>
<tr><td></td><th>IPv4</td><th>IPv6</th></tr>
<tr><td>Hub GRE address</td><td>172.18.0.&lt;hub id&gt;</td><td>fd00::&lt;hub id&gt;</td></tr>
<tr><td>Site VPNc GRE address</td><td>172.18.&lt;site id&gt;.&lt;vpnc id&gt;</td><td>fd00::&lt;site id&gt;:&lt;vpnc id&gt;</td></tr>
<tr><td>Site subnet</td><td>10.&lt;site id&gt;.0.0/16</td><td>fd00:0:&lt;site id&gt;::/48</td></tr>
</table>

IPv6 addresses can be left undefined if only IPv4 is used in the VPN.

After setting up the CA configuration, generate the root key and certificate:

<pre>dmvpn-ca root-cert generate
</pre>

Create the configuration for hubs and sites. In this example, there are two
hubs and two sites. Each site has two VPN concentrators (VPNcs) for redundancy.

<pre>dmvpn-ca hub create
dmvpn-ca gre-addr add 172.18.0.1 hub 1
dmvpn-ca gre-addr add fd00::1 hub 1

dmvpn-ca hub create
dmvpn-ca gre-addr add 172.18.0.2 hub 2
dmvpn-ca gre-addr add fd00::2 hub 2

dmvpn-ca site add FIN
dmvpn-ca subnet add 10.1.0.0/16 site FIN
dmvpn-ca subnet add fd00:0:1::/48 site FIN
dmvpn-ca vpnc create site FIN
dmvpn-ca gre-addr add 172.18.1.1 site FIN vpnc 1
dmvpn-ca gre-addr add fd00::1:1 site FIN vpnc 1
dmvpn-ca vpnc create site FIN
dmvpn-ca gre-addr add 172.18.1.2 site FIN vpnc 2
dmvpn-ca gre-addr add fd00::1:2 site FIN vpnc 2

dmvpn-ca site add SWE
dmvpn-ca subnet add 10.2.0.0/16 site SWE
dmvpn-ca subnet add fd00:0:2::/48 site SWE
dmvpn-ca vpnc create site SWE
dmvpn-ca gre-addr add 172.18.2.1 site SWE vpnc 1
dmvpn-ca gre-addr add fd00::2:1 site SWE vpnc 1
dmvpn-ca vpnc create site SWE
dmvpn-ca gre-addr add 172.18.2.2 site SWE vpnc 2
dmvpn-ca gre-addr add fd00::2:2 site SWE vpnc 2
</pre>

Finally, generate the keys and certificates for the hubs and VPNcs:

<pre>dmvpn-ca cert generate
</pre>

This commands generates a PFX file for each hub and VPNc, for example:

<pre># ls
FIN_1.9D6JLGHlLmTG4bVR.pfx  SWE_1.caN3yapMTpZbIVP4.pfx  _1.hy62AqLIUJcFuT1U.pfx
FIN_2.fXbw4HwqkLXlIbtk.pfx  SWE_2.0BElySor2L8fm6e2.pfx  _2.cDLUvB8XALBkD2vP.pfx
</pre>

The encrypted file contains the individual certificate, the corresponding
private key, and the root certificate. The password is embedded in the file
name. The file should be renamed when using out-of-band delivery for the
password.

## Setting Up CRL Distribution Point

In this example, the CA host serves also as the CRL distribution point. It is
assumed that `crl.example.com` resolves to the IP address of that host.

Execute the following commands on the CA host to set up CRL distribution:

<pre>apk add dmvpn-crl-dp
dmvpn-crl-update
rc-update add lighttpd
rc-service lighttpd start
</pre>

## Setting Up a Hub

Install the `dmvpn` package on the host to be configured as a DMVPN hub. It is
assumed that the network configuration of the host is already in place.

<pre>apk add dmvpn
</pre>

Execute the setup tool using the hub's PFX file, answering the questions
prompted. The password is deduced from the file name unless renamed. Enter the
prefix lengths that uniquely identify the site. The default values are valid
for this example. The prefix length may vary among the sites, in which case the
maximum length should be given.

<pre>setup-dmvpn &lt;pfx file&gt;
</pre>

The hub is now operational. The tool sets up the `iptables` firewall
automatically using `awall`. Firewall for IPv6 (`ip6tables`) is set up only if
IPv6 addresses are defined for the VPN.

Due to an unresolved issue, you may have to reboot the host if VPN tunnels are
not established within a reasonable time.

## Setting Up a Site VPNc (Spoke)

Install the `dmvpn` package on the host to be configured as a DMVPN spoke. It
is assumed that the host is already configured as a router to the site subnet.

<pre>apk add dmvpn
</pre>

Execute the setup tool using the spoke's PFX file, answering the questions
prompted. The password is deduced from the file name unless renamed.

<pre>setup-dmvpn &lt;pfx file&gt;
</pre>

The spoke is now operational. Firewall rules are updated automatically if they
are managed using `awall`.

Due to an unresolved issue, you may have to reboot the host if VPN tunnels are
not established within a reasonable time.
