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

data "aws_security_groups" "for-prometheus" {
  tags = {
    Name = "for-promethues"
  }
}
data "aws_subnet_ids" "public_subnet" {
  vpc_id = data.aws_vpc.monitor-vpc.id
  tags = {
    Name = "pub-sn"
  }
}
data "aws_subnet_ids" "private_subnet" {
  vpc_id = data.aws_vpc.monitor-vpc.id
  tags = {
    Name = "pri-sn"
  }
}
resource "aws_instance" "prometheus" {
  count                   = 2
  ami                     = "ami-0ec225b5e01ccb706" //amz linux 2
  instance_type           = "t2.micro"
  key_name                = "bastionkey"
  subnet_id               = tolist(data.aws_subnet_ids.private_subnet.ids)[count.index]
  vpc_security_group_ids  = data.aws_security_groups.for-prometheus.ids
  tags = {
    Name = "prometheus-${count.index +1}"
  }
}
output "prometheus-ids" {
  value = aws_instance.prometheus.*.id
}
locals {
  for_each = {
    for instance_id in prometheus-ids:
  }
}
