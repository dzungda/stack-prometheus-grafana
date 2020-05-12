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
data "aws_security_groups" "for-grafana" {
    tags = {
    Name = "for-grafana"
  }
}
data "aws_security_groups" "for-prometheus" {
  tags = {
    Name = "for-promethues"
  }
}
resource "aws_lb" "stack_monitor" {
  name                      = "alb"
  internal                  = true
  load_balancer_type        = "application"
  security_groups           = data.aws_security_groups.for-prometheus.ids
  subnets                   = data.aws_subnet_ids.private_subnet.ids
  enable_http2              = true
  ip_address_type           = "ipv4"
  drop_invalid_header_fields = false
  tags = {
      Name = "alb-stack-monitor"
  }
}
resource "aws_lb_target_group" "stack_monitor" {
    name                    = "target-group-stack-monitor"
    port                    = "9090"
    protocol                = "HTTP"
    vpc_id                  = data.aws_vpc.monitor-vpc.id
    target_type             = "instance"
    health_check {
        interval            = 30
        path                = "/graph"
        port                = 9090
        healthy_threshold   = 3
        unhealthy_threshold = 2
        timeout             = 5
        protocol            = "HTTP"
    }
    stickiness {
      type            = "lb_cookie"
      cookie_duration = 86400
    }
}
/*
resource "aws_lb_cookie_stickiness_policy" "foo" {
    name                    = "stickiness"
    load_balancer           = aws_lb.stack_monitor.id
    lb_port                 = 9090
    cookie_expiration_period = 86400
}
*/
resource "aws_lb_listener" "stack_monitor" {
  load_balancer_arn         = aws_lb.stack_monitor.arn
  port                      = "9090"
  protocol                  = "HTTP"
  default_action {
      type                  = "forward"
      target_group_arn      = aws_lb_target_group.stack_monitor.arn
  }
}

resource "aws_lb_target_group_attachment" "target_1" {
    target_group_arn        = aws_lb_target_group.stack_monitor.arn
    target_id               = var.prometheus-2-id
}

resource "aws_lb_target_group_attachment" "target_2" {
    target_group_arn        = aws_lb_target_group.stack_monitor.arn
    target_id               = var.prometheus-2-id
}

/*
resource "aws_lb_target_group_attachment" "tgr_attachment" {
  target_group_arn = aws_lb_target_group.stack_monitor.arn
  target_id        = [for sc in range(2) : var.prometheus-ids[sc]]
  port             = 9090
}
*/