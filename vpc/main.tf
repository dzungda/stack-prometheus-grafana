provider "aws" {
  region  = var.region
  profile = var.profile
}
##### VPC ##### 
data "aws_availability_zones" "default" {}

module "vpc" {
  source                = "https://github.com/dzungda/aws-terraform-module/tree/master/terraform-aws-vpc"
  cidr                  = var.cidr
  azs                   = data.aws_availability_zones.default.names
  single_nat_gateway    = true
  private_subnets       = var.private_subnets
  private_subnet_tags   = {
    Name = var.private_subnet_tags
  }
  public_subnet_tags    = {
    Name = var.public_subnet_tags
  }
  public_subnets        = var.public_subnets
  enable_ipv6           = false

  tags = {
    Name = "monitor-vpc"
  }
  vpc_tags = {
    Name = "monitor-vpc"
  }

}

