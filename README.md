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
## Inputs


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