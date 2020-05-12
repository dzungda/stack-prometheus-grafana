terraform {
  backend "s3" {
    acl            = "private"
    bucket         = "dungda-terraform-state"
    key            = "terraform/stack-grafana-promethues/sg/terraform.tfstate"
    region         = "ap-southeast-1"
    profile        = "default"
    dynamodb_table = "dungda-tf-state-lock"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket  = "dungda-terraform-state"
    key     = "terraform/stack-grafana-promethues/vpc/terraform.tfstate"
    region  = "ap-southeast-1"
    profile = "default"
  }
}
