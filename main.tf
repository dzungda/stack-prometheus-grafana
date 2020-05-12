provider "aws" {
  profile = "default"
  region  = "ap-southeast-1"
}
module "ec2" {
  source = "./ec2"
#  prometheus-key = module.prometheus-key.this_key_pair_key_name
}
module "alb" {
  source         = "./alb"
  prometheus-1-id = module.ec2.prometheus-ids[0]
  prometheus-2-id = module.ec2.prometheus-ids[1]
  
}
/*
module "prometheus-key" {
  source = "https://github.com/dzungda/aws-terraform-module/tree/master/terraform-aws-keypair"

  key_name   = "prometheus-key"
  public_key = "./.ssh/for-grafana.pub"

  tags = {
    Name = "prometheus-key"
  }
}
*/