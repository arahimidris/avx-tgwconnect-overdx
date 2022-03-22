# Aviatrix TGW Cnnect over DX on AWS Demo Topology

The code provided is for demo purposes only.

![Aviatrix TGW Cnnect over DX on AWS Demo Topology](images/demo.png "Aviatrix TGW Cnnect over DX on AWS Demo Topology")

Password hash for API (admin-api user) is generated via the "request password-hash" CLI command.
https://knowledgebase.paloaltonetworks.com/KCSArticleDetail?id=kA10g000000PPkCCAW

- Default username/password: admin/Aviatrix123#
- Default api username/password: admin-api/Aviatrix123#

## Prerequisites

Please make sure you have:
- Aviatrix Controller 6.6
- AWS access accounts are onboarded. Variable for AWS access account is 'aws_account_name'

## Variables

To run this project, you will need to provide the variables listed in Inputs Section


## Run Locally

Clone the project

```bash
git clone https://github.com/arahimidris/avx66-tgw-connect-overdx.git
```

Go to the project directory

```bash
cd avx-tgwconnect-overdx
```

Set variables using tfvar or environment variables


Terraform workflow

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

## Outputs

After complete deployment , the EC2 instance in Prod VPCs should be able to access prefixes advertised via on-prem device in prod VRF.

Below is the output of show ip bgp fromt he VyoS appliance

arahim@AR-onprem:~$   show ip route vrf underlay
Codes: K - kernel route, C - connected, S - static, R - RIP,
       O - OSPF, I - IS-IS, B - BGP, E - EIGRP, N - NHRP,
       T - Table, v - VNC, V - VNC-Direct, A - Babel, D - SHARP,
       F - PBR, f - OpenFabric,
       > - selected route, * - FIB route, q - queued, r - rejected, b - backup

VRF underlay:
K>* 0.0.0.0/0 [255/8192] unreachable (ICMP unreachable), 04w1d00h
B>* 10.0.0.0/24 [20/0] via 192.168.1.0, eth1, weight 1, 01:25:55
C>* 10.1.0.1/32 is directly connected, dum1, 03w6d17h
C>* 192.168.1.0/31 is directly connected, eth1, 04w1d00h

arahim@AR-onprem:~$   show ip route vrf prod 
Codes: K - kernel route, C - connected, S - static, R - RIP,
       O - OSPF, I - IS-IS, B - BGP, E - EIGRP, N - NHRP,
       T - Table, v - VNC, V - VNC-Direct, A - Babel, D - SHARP,
       F - PBR, f - OpenFabric,
       > - selected route, * - FIB route, q - queued, r - rejected, b - backup

VRF prod:
K>* 0.0.0.0/0 [255/8192] unreachable (ICMP unreachable), 04w1d00h
C>* 10.11.0.0/24 is directly connected, dum11, 04w1d00h
C>* 169.254.100.0/29 is directly connected, tun0, 04w1d00h
C>* 169.254.100.8/29 is directly connected, tun1, 04w1d00h
C>* 169.254.100.16/29 is directly connected, tun2, 04w1d00h
C>* 169.254.100.24/29 is directly connected, tun3, 04w1d00h
B>* 172.16.0.0/24 [20/100] via 169.254.100.2, tun0, weight 1, 00:00:49
  *                        via 169.254.100.3, tun0, weight 1, 00:00:49
  *                        via 169.254.100.26, tun3, weight 1, 00:00:49
  *                        via 169.254.100.27, tun3, weight 1, 00:00:49

arahim@AR-onprem:~$   show ip route vrf nonprod
Codes: K - kernel route, C - connected, S - static, R - RIP,
       O - OSPF, I - IS-IS, B - BGP, E - EIGRP, N - NHRP,
       T - Table, v - VNC, V - VNC-Direct, A - Babel, D - SHARP,
       F - PBR, f - OpenFabric,
       > - selected route, * - FIB route, q - queued, r - rejected, b - backup

VRF nonprod:
K>* 0.0.0.0/0 [255/8192] unreachable (ICMP unreachable), 04w1d00h
C>* 10.12.0.0/24 is directly connected, dum21, 04w1d00h
C>* 169.254.101.0/29 is directly connected, tun4, 04w1d00h
C>* 169.254.101.8/29 is directly connected, tun5, 04w1d00h
C>* 169.254.101.16/29 is directly connected, tun6, 04w1d00h
C>* 169.254.101.24/29 is directly connected, tun7, 04w1d00h
B>* 172.16.1.0/24 [20/100] via 169.254.101.2, tun4, weight 1, 01:12:50
  *                        via 169.254.101.3, tun4, weight 1, 01:12:50


arahim@AR-onprem:~$ show ip bgp vrf all summ

Instance nonprod:

IPv4 Unicast Summary:
BGP router identifier 10.12.0.1, local AS number 64522 vrf-id 6
BGP table version 31
RIB entries 3, using 576 bytes of memory
Peers 8, using 170 KiB of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt
169.254.101.2   4      65001    100336    167308        0    0    0 01:13:51            1        2
169.254.101.3   4      65001    100317    167279        0    0    0 01:13:33            1        2
169.254.101.10  4      65001     92276    153901        0    0    0 04:57:49      Connect        0
169.254.101.11  4      65001     92301    153934        0    0    0 04:58:02      Connect        0
169.254.101.18  4      65001     91843    153177        0    0    0 05:06:27      Connect        0
169.254.101.19  4      65001     91863    153187        0    0    0 05:06:23      Connect        0
169.254.101.26  4      65001     45125     75277        0    0    0 05:04:11      Connect        0
169.254.101.27  4      65001     45123     75285        0    0    0 05:04:30      Connect        0

Total number of neighbors 8

Instance prod:

IPv4 Unicast Summary:
BGP router identifier 10.11.0.1, local AS number 64521 vrf-id 7
BGP table version 52
RIB entries 3, using 576 bytes of memory
Peers 8, using 170 KiB of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt
169.254.100.2   4      65001    101530    169351        0    0    0 01:17:31            1        2
169.254.100.3   4      65001    101511    169313        0    0    0 01:17:32            1        2
169.254.100.10  4      65001     99087    165264        0    0    0 04:59:52      Connect        0
169.254.100.11  4      65001     99077    165238        0    0    0 04:59:45      Connect        0
169.254.100.18  4      65001     99232    165504        0    0    0 04:51:58      Connect        0
169.254.100.19  4      65001     99265    165551        0    0    0 04:51:41      Connect        0
169.254.100.26  4      65001     98666    164551        0    0    0 00:01:34            1        2
169.254.100.27  4      65001     98680    164564        0    0    0 00:01:31            1        2

Total number of neighbors 8

Instance underlay:

IPv4 Unicast Summary:
BGP router identifier 10.1.0.1, local AS number 64512 vrf-id 8
BGP table version 11
RIB entries 5, using 960 bytes of memory
Peers 1, using 21 KiB of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt
192.168.1.0     4      65000     50466     76329        0    0    0 01:36:15            1        3

Total number of neighbors 1


## Required Inputs


| Name | Description | Default | Required |
|------|-------------|---------|----------|
| username | Aviatrix controller username | None | yes |
| password | Aviatrix controller password | None | yes |
| controller_ip | Aviatrix controller ip address | None | yes |
| aws_account_name | AWS account name | None | yes |
| dxcon_name | AWS Direct Connect connection name | None | yes |
| vm_admin_password | Password to login to Test EC2 isntances | None | yes |
| num_connect_peers | Number of connect peers per TGW Connect attachment | `4` | yes |
| gw.dxgw.asn | DXGW BGP ASN | `65000` | yes |
| gw.dxgw.name | DXGW Name| `tf-dxgw-tgw-connect` | yes |
| gw.ce.prod_asn | BGP ASN of Prod VRF on CE | `64521` | yes |
| gw.ce.nonprod_asn | BGP ASN of NonProd VRF on CE | `64522` | yes |
| gw.ce.connect_peerip | Tunnel Source IP on CE , advertised on underlay VRF| `10.1.0.1` | yes |
| gw.tgw.asn | AWS Transit Gateway (TGW) BGP ASN | `65001` | yes |
| gw.tgw.name |  AWS Transit Gateway (TGW) name| `TGW-Connect-demo` | yes |
| gw.tgw.cidr | AWS Transit Gateway (TGW) CIDR - used as Tunnel Source for TGW Connnect Peering | `10.0.0.0/24` | yes |
| tvif.name | Tranist VIF name | `tvif-tgwconnect` | yes |
| tvif.mtu | Tranist VIF MTU | `8500` | yes |
| tvif.vlanid | Tranist VIF VLAN ID (incase of hosted connection) | `309` | yes |
| tvif.amzn_address| Tranist VIF Amazon side IP (used on DXGW/Amazon Logical Device)  | `"192.168.1.0/31` | yes |
| tvif.ce_address | Tranist VIF Customer side IP  | `192.168.1.1/31` | yes |
| tvif.bgp_authkey | Tranist VIF BGP MD5  | `Aviatrix123` | yes |
| tvif.ce_asn | BGP ASN used on CE device in underlay VRF  | `64512` | yes |
| prod_inside_cidr | BGP inside CIDR for Prod Connect Peering | `"169.254.100.0/29", "169.254.100.8/29", "169.254.100.16/29", "169.254.100.24/29"` | yes |
| nonprod_inside_cidr | BGP inside CIDR for Non-Prod Connect Peering | `"169.254.101.0/29", "169.254.101.8/29", "169.254.101.16/29", "169.254.101.24/29"` | yes |
| tgw_peerip_prod | TGW Peer IP (tunnel source) for Prod Connect Peers | `"10.0.0.0", "10.0.0.1", "10.0.0.2", "10.0.0.3"` | yes |
| tgw_peerip_nonprod |  TGW Peer IP (tunnel source) for NonProd Connect Peers | `"10.0.0.4", "10.0.0.5", "10.0.0.6", "10.0.0.7"` | yes |
| environments | Specify TGW different Connect attachment types | `"Prod-Connect", "NonProd-Connect"` | yes |
| mandatory-domains | Specify mandatory TGW domains required by TGW orchestrator | `"Shared_Service_Domain", "Aviatrix_Edge_Domain", "Default_Domain"` | yes |
| domains | Specify additional TGW Security Domains | `"DX", "Prod", "NonProd"` | yes |
| vpcs.prod.vpccidr |  NonProd VPC CIDR  | `172.16.0.0/24` | yes |
| vpcs.prod.aws_region | AWS Region for NonProd VPC | `us-east-2` | yes |
| vpcs.prod.aws_account_name | AWS account used to create NonProd VPC | `arahim-corp-aws` | yes |
| vpcs.prod.create_ec2 | Create test EC2 instance in NonProd VPC | `true` | yes |
| vpcs.prod.secdomain | AWS TGW Security Domain to assosciate NonProd VPC | `Prod` | yes |
| vpcs.nonprod.vpccidr |  NonProd VPC CIDR  | `172.16.1.0/24` | yes |
| vpcs.nonprod.aws_region | AWS Region for NonProd VPC | `us-east-2` | yes |
| vpcs.nonprod.aws_account_name | AWS account used to create NonProd VPC | `arahim-corp-aws` | yes |
| vpcs.nonprod.create_ec2 | Create test EC2 instance in NonProd VPC | `true` | yes |
| vpcs.nonprod.secdomain | AWS TGW Security Domain to assosciate NonProd VPC | `NonProd` | yes |