##################################################################
# Data source to get DX Connection ID
##################################################################
data "aws_dx_connection" "dxcon" {
  name =var.dxcon_name
}


##################################################################
# Create TVIF
##################################################################
resource "aws_dx_transit_virtual_interface" "tvif" {
  connection_id = data.aws_dx_connection.dxcon.id
  dx_gateway_id  = aws_dx_gateway.dxgw.id 
  name           = var.tvif.name
  vlan           = var.tvif.vlanid
  address_family = "ipv4"
  bgp_asn        = var.tvif.ce_asn
  amazon_address = var.tvif.amzn_address
  customer_address = var.tvif.ce_address
  mtu = var.tvif.mtu
  bgp_auth_key = var.tvif.bgp_authkey
}

output "aws_dxcon_id" {
  value = data.aws_dx_connection.dxcon.id
}

output "aws_tvif_id" {
  value = aws_dx_transit_virtual_interface.tvif.id
}

##################################################################
# Create DXGW
##################################################################
resource "aws_dx_gateway" "dxgw" {
  name            = var.gw.dxgw.name
  amazon_side_asn = var.gw.dxgw.asn
}

output "aws_dxgw_id" {
  value = aws_dx_gateway.dxgw.id
}

