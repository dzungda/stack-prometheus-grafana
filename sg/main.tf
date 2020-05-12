provider "aws" {
  profile = "default"
  region  = "ap-southeast-1"
}
##### VPC ##### 
data "aws_availability_zones" "default" {}
data "aws_vpc" "monitor-vpc" {
  tags = {
    Name = "monitor-vpc"
  }
}
#### Security Group #####
module "sg_grafana" {
  source      = "https://github.com/dzungda/aws-terraform-module/tree/master/terraform-aws-sg"
  name        = "for-grafana"
  description = "for grafana instance"
  vpc_id      = data.aws_vpc.monitor-vpc.id
  tags = {
    Name = "for-grafana"
  }
  ingress_cidr_blocks = ["0.0.0.0/0", "113.164.234.70/32"]
  ingress_rules       = ["ssh-tcp"]
  #  ingress_cdir_block = ["0.0.0.0/0"]
  #  computed_ingress_rules = ["ssh-tcp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 3000
      to_port     = 3000
      protocol    = 6
      description = "grafana_http"
      cidr_block  = "113.164.234.70/32, 172.16.0.0/16"
    },
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  #  number_of_computed_ingress_rules = 1
}

module "sg_promethues" {
  source      = "https://github.com/dzungda/aws-terraform-module/tree/master/terraform-aws-sg"
  name        = "for-promethues"
  description = "for promomethues instances"
  vpc_id      = data.aws_vpc.monitor-vpc.id
  tags = {
    Name = "for-promethues"
  }
  ingress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "172.16.0.0/16"
    },
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}
