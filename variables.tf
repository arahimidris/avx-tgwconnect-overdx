variable "username" {}
variable "password" {}
variable "controller_ip" {}
variable "aws_account_name" {}
variable "aws_region1" {}
variable "dxcon_name" {}
variable "vm_admin_password" {}

variable "num_connect_peers" {
  default = 4 /* min value is zero max value is 4 per connect attachment */
}


variable "gw" {
  default = {
    dxgw = {
      asn  = 65000
      name = "tf-dxgw-tgw-connect"
    }
    ce = {
      prod_asn       = 64521
      nonprod_asn    = 64522
      connect_peerip = "10.1.0.1"
    }
    tgw = {
      asn  = 65001
      cidr = "10.0.0.0/24"
      name = "TGW-Connect-demo"
    }
  }
}

variable "tvif" {
  default = {
    first = {
      name         = "tvif-tgwconnect"
      mtu          = 8500
      vlanid       = 309
      amzn_address = "192.168.1.0/31"
      ce_address   = "192.168.1.1/31"
      bgp_authkey = "Aviatrix123"
      ce_asn          = 64512
    }
  }
}
variable "prod_inside_cidr" {
  default = ["169.254.100.0/29", "169.254.100.8/29", "169.254.100.16/29", "169.254.100.24/29"]
}

variable "nonprod_inside_cidr" {
  default = ["169.254.101.0/29", "169.254.101.8/29", "169.254.101.16/29", "169.254.101.24/29"]
}

variable "tgw_peerip_prod" {
  default = ["10.0.0.0", "10.0.0.1", "10.0.0.2", "10.0.0.3"]
}

variable "tgw_peerip_nonprod" {
  default = ["10.0.0.4", "10.0.0.5", "10.0.0.6", "10.0.0.7"]
}


variable "environments" {
  default = ["Prod-Connect", "NonProd-Connect"]
}

variable "mandatory-domains" {
  default = ["Shared_Service_Domain", "Aviatrix_Edge_Domain", "Default_Domain"]
}

variable "domains" {
  default = ["DX", "Prod", "NonProd"]
}

variable "vpcs" {
  default = {
    nonprod = {
      vpc_cidr         = "172.16.1.0/24"
      aws_region       = "us-east-2"
      aws_account_name = "arahim-corp-aws"
      create_ec2       = true
      secdomain        = "NonProd"
    }
    prod = {
      vpc_cidr         = "172.16.0.0/24"
      aws_region       = "us-east-2"
      aws_account_name = "arahim-corp-aws"
      create_ec2       = true
      secdomain        = "Prod"
    }
  }
}

locals {
  #Create connections based on var.mandatory-domains
  connections = flatten([
    for domain in var.mandatory-domains : [
      for connected_domain in slice(var.mandatory-domains, index(var.mandatory-domains, domain) + 1, length(var.mandatory-domains)) : {
        domain1 = domain
        domain2 = connected_domain
      }
    ]
  ])

  #Create map to be used in for_each
  connections_map = {
    for connection in local.connections : "${connection.domain1}:${connection.domain2}" => connection
  }
}
