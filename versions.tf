terraform {
  required_providers {
    aviatrix = {
      source  = "AviatrixSystems/aviatrix"
      version = "2.21.1-6.6.ga" #6.6
    }
    aws = {
      source = "hashicorp/aws"
    }

  }
  required_version = ">= 1.0"
}
