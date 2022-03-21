# # Create AWS TGW

resource "aviatrix_aws_tgw" "aws_tgw" {
  account_name                      = var.aws_account_name
  aws_side_as_number                = var.gw.tgw.asn
  manage_vpc_attachment             = false
  manage_transit_gateway_attachment = false
  manage_security_domain            = false
  region                            = var.aws_region1
  tgw_name                          = var.gw.tgw.name
  enable_multicast                  = true
  cidrs                             = [var.gw.tgw.cidr]
}

resource "aviatrix_aws_tgw_security_domain" "mandatory-domains" {
  for_each = toset(var.mandatory-domains)
  name     = each.value
  tgw_name = aviatrix_aws_tgw.aws_tgw.tgw_name
}

resource "aviatrix_aws_tgw_security_domain" "domains" {
  for_each   = toset(var.domains)
  name       = each.value
  tgw_name   = aviatrix_aws_tgw.aws_tgw.tgw_name
  depends_on = [aviatrix_aws_tgw_security_domain.mandatory-domains]
}


# Create AWS TGW Security Domain Connection policies

resource "aviatrix_aws_tgw_peering_domain_conn" "ss_connections" {
  for_each     = local.connections_map
  tgw_name1    = aviatrix_aws_tgw.aws_tgw.tgw_name
  tgw_name2    = aviatrix_aws_tgw.aws_tgw.tgw_name
  domain_name1 = each.value.domain1
  domain_name2 = each.value.domain2
  depends_on   = [aviatrix_aws_tgw_security_domain.mandatory-domains]
}

# # Create TGW DX attachment with Allowed Prefix list

resource "aviatrix_aws_tgw_directconnect" "aws_tgw_directconnect_1" {
  tgw_name                      = aviatrix_aws_tgw.aws_tgw.tgw_name
  security_domain_name          = aviatrix_aws_tgw_security_domain.domains["DX"].name
  directconnect_account_name    = var.aws_account_name
  dx_gateway_id                 = aws_dx_gateway.dxgw.id
  allowed_prefix                = var.gw.tgw.cidr
  enable_learned_cidrs_approval = false
}


# # Create TGW Connect attachment for Prod and Connect Peers

resource "aviatrix_aws_tgw_connect" "aws_tgw_connect_prod" {
  tgw_name             = aviatrix_aws_tgw.aws_tgw.tgw_name
  connection_name      = var.environments[0]
  transport_vpc_id     = aws_dx_gateway.dxgw.id
  security_domain_name = aviatrix_aws_tgw_security_domain.domains["Prod"].name
  depends_on           = [aviatrix_aws_tgw_directconnect.aws_tgw_directconnect_1]
}

resource "aviatrix_aws_tgw_connect_peer" "connect_prod_peer" {
  count                 = var.num_connect_peers
  tgw_name              = aviatrix_aws_tgw.aws_tgw.tgw_name
  connection_name       = aviatrix_aws_tgw_connect.aws_tgw_connect_prod.connection_name
  connect_attachment_id = aviatrix_aws_tgw_connect.aws_tgw_connect_prod.connect_attachment_id
  peer_as_number        = var.gw.ce.prod_asn
  peer_gre_address      = var.gw.ce.connect_peerip
  tgw_gre_address       = var.tgw_peerip_prod[count.index]
  bgp_inside_cidrs      = [var.prod_inside_cidr[count.index]]
  connect_peer_name     = "${var.environments[0]}-Peer${count.index + 1}"
}


# # Create TGW Connect attachment for Non-Prod and Connect Peers

resource "aviatrix_aws_tgw_connect" "aws_tgw_connect_nonprod" {
  tgw_name             = aviatrix_aws_tgw.aws_tgw.tgw_name
  connection_name      = var.environments[1]
  transport_vpc_id     = aws_dx_gateway.dxgw.id
  security_domain_name = aviatrix_aws_tgw_security_domain.domains["NonProd"].name
  depends_on           = [aviatrix_aws_tgw_directconnect.aws_tgw_directconnect_1]
}

resource "aviatrix_aws_tgw_connect_peer" "connect_nonprod_peer" {
  count                 = var.num_connect_peers
  tgw_name              = aviatrix_aws_tgw.aws_tgw.tgw_name
  connection_name       = aviatrix_aws_tgw_connect.aws_tgw_connect_nonprod.connection_name
  connect_attachment_id = aviatrix_aws_tgw_connect.aws_tgw_connect_nonprod.connect_attachment_id
  peer_as_number        = var.gw.ce.nonprod_asn
  peer_gre_address      = var.gw.ce.connect_peerip
  tgw_gre_address       = var.tgw_peerip_nonprod[count.index]
  bgp_inside_cidrs      = [var.nonprod_inside_cidr[count.index]]
  connect_peer_name     = "${var.environments[1]}-Peer${count.index + 1}"
}

output "aws_tgw_id" {
  value = aviatrix_aws_tgw.aws_tgw.id
}