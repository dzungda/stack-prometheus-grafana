terraform {
  backend "s3" {
    acl            = "private"
    bucket         = "dungda-terraform-state"
    key            = "terraform/stack-grafana-promethues/terraform.tfstate"
    region         = "ap-southeast-1"
    profile        = "default"
    dynamodb_table = "dungda-tf-state-lock"
  }
}
