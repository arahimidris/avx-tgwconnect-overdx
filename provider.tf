provider "aviatrix" {
  controller_ip = var.controller_ip
  username      = var.username
  password      = var.password
}

provider "aws" {
  region = var.aws_region1
}


# provider "aws" {
#   alias = syd
#   region = var.aws_region2
# }
