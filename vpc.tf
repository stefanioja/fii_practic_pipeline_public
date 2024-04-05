# #region locals

# locals {
#   name   = "fii-practic-${var.env}"
#   region = "eu-central-1"

#   vpc_cidr = "10.0.0.0/16"
#   azs      = ["eu-central-1a", "eu-central-1b"]

#   tags = {
#     Use = local.name
#   }
# }

# #endregion locals

# #region vpc

# module "vpc" {

#   source  = "terraform-aws-modules/vpc/aws"
#   version = "5.0.0"

#   name = local.name
#   cidr = local.vpc_cidr

#   azs              = local.azs
#   private_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
#   public_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 4)]
#   database_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 8)]

#   private_subnet_names  = ["Private Subnet One", "Private Subnet Two"]
#   database_subnet_names = ["DB Subnet One"]

#   create_database_subnet_group  = true
#   manage_default_network_acl    = false
#   manage_default_route_table    = false
#   manage_default_security_group = false

#   single_nat_gateway = true
#   enable_nat_gateway = true

#   tags = local.tags
# }

# #endregion vpc

# # ✓ VPC