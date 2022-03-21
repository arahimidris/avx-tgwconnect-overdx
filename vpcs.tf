module "myvpc" {
  for_each             = var.vpcs
  source               = "./vpc"
  name                 = each.key
  vpc_cidr             = each.value.vpc_cidr
  aws_region           = each.value.aws_region
  aws_account_name     = each.value.aws_account_name
  create_ec2           = each.value.create_ec2
  vm_admin_password    = var.vm_admin_password
  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name
}

################################################################################
# TGW attachment for Non-Prod
################################################################################

resource "aviatrix_aws_tgw_vpc_attachment" "vpc_tgw_attachment" {
  for_each             = var.vpcs
  tgw_name             = aviatrix_aws_tgw.aws_tgw.tgw_name
  region               = each.value.aws_region
  vpc_account_name     = each.value.aws_account_name
  subnets              = "${module.myvpc[each.key].intra_subnets[0]}, ${module.myvpc[each.key].intra_subnets[1]}"
  security_domain_name = each.value.secdomain
  vpc_id               = module.myvpc[each.key].vpc_id
  depends_on           = [aviatrix_aws_tgw_security_domain.domains]
}