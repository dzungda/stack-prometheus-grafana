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
resource "aws_instance" "grafana" {
  count                       = 1
  ami                         = "ami-0ec225b5e01ccb706" //amz linux 2
  instance_type               = "t2.micro"
  key_name                    = "bastionkey"
  associate_public_ip_address = true
  subnet_id                   = tolist(data.aws_subnet_ids.public_subnet.ids)[0]
  vpc_security_group_ids      = data.aws_security_groups.for-grafana.ids
  tags = {
    Name = "grafana"
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



/*
module "grafana-key" {
  source = "https://github.com/dzungda/aws-terraform-module/tree/master/terraform-aws-keypair"

  key_name   = "grafana-key"
  public_key = var.grafana_public_key

  tags = {
    Name = "grafana-key"
  }
}
module "promethues-key" {
  source = "https://github.com/dzungda/aws-terraform-module/tree/master/terraform-aws-keypair"

  key_name   = "prometheus-key"
  public_key = var.prometheus_public_key

  tags = {
    Name = "prometheus-key"
  }
}
module "grafana-instance" {
  source                       = "https://github.com/dzungda/aws-terraform-module/tree/master/terraform-aws-ec2"
  instance_count               = 1
  name                         = "grafana-instance"
  vpc_security_group_ids       = data.aws_security_groups.for-grafana.ids
  ami                          = var.ami           #"ami-0ec225b5e01ccb706" #amz linux 2
  key_name                     = "bastionkey"      #module.keypair-grafana.this_key_pair_key_name
  instance_type                = var.instance_type #"t2.medium"
  subnet_id                    = tolist(data.aws_subnet_ids.public_subnet.ids)[0]
  monitoring                   = true
  associate_public_ip_address = true
  tags = {
    Name = "grafana"
  }
}


module "prometheus-instance-1" {
  source                 = "https://github.com/dzungda/aws-terraform-module/tree/master/terraform-aws-ec2"
  instance_count         = 1
  name                   = "promethues-instance-1"
  vpc_security_group_ids = data.aws_security_groups.for-prometheus.ids
  key_name               = "bastionkey"      #module.prometheus-key.this_key_pair_key_name
  ami                    = var.ami           #"ami-0ec225b5e01ccb706" #amz linux 2
  instance_type          = var.instance_type #"t2.medium"
  monitoring             = true
  subnet_id              = tolist(data.aws_subnet_ids.private_subnet.ids)[0]
  tags = {
    Name = "prometheus-1"
  }
}

module "prometheus-instance-2" {
  source                 = "https://github.com/dzungda/aws-terraform-module/tree/master/terraform-aws-ec2"
  instance_count         = 1
  name                   = "promethues-instance-2"
  vpc_security_group_ids = data.aws_security_groups.for-prometheus.ids
  key_name               = "bastionkey"      #module.prometheus-key.this_key_pair_key_name
  ami                    = var.ami           #"ami-0ec225b5e01ccb706" #amz linux 2
  instance_type          = var.instance_type #"t2.medium"
  monitoring             = true
  subnet_id              = tolist(data.aws_subnet_ids.private_subnet.ids)[1]
  tags = {
    Name = "prometheus-2"
  }
}

module "alb-internal" {
  source              = "https://github.com/dzungda/aws-terraform-module/tree/master/terraform-aws-alb"
  name                = "alb-prometheus"
  load_balancer_type  = "application"
  vpc_id              = data.aws_vpc.monitor-vpc.id
  security_groups     = data.aws_security_groups.for-prometheus.ids
  subnets             = data.aws_subnet_ids.private_subnet.ids
  http_tcp_listeners  = [
    {
      port               = 9090
      protocol           = "HTTP"
      target_group_index = 0
      # action_type        = "forward"

    },
  ]
  target_groups = [
    {
      name      = "prometheus-slave"
      backend_protocol  = "HTTP"
      backend_port      = 9090
      target_type       = "instance"
      vpc_id            = data.aws_vpc.monitor-vpc.id
      stickiness        = {
        enable          = true
        type            = "lb_cookie"
        cookie_duration = 86400
      }
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/graph"
        port                = 9090
        healthy_threshold   = 3
        unhealthy_threshold = 2
        timeout             = 5
        protocol            = "HTTP"
      }
    } 
  ] 

}
#ELB attachments

resource "aws_lb_target_group_attachment" "tag1" {
  target_group_arn = tolist(module.alb-internal.target_group_arns)[0]
  target_id        = tolist(module.prometheus-instance-1.id)[0]
  port             = 9090
}
resource "aws_lb_target_group_attachment" "tag2" {
  target_group_arn = tolist(module.alb-internal.target_group_arns)[0]
  target_id        = tolist(module.prometheus-instance-2.id)[0]
  port             = 9090
}

/*
output "test" {
  value = tolist(module.alb-internal.target_group_arns)[0]
}

resource "aws_launch_configuration" "prometheus" {
  name                    = "prometheues"
  image_id                = var.ami
  instance_type           = var.instance_type
  key_name                = "bastionkey"

  enable_monitoring       = true
  
#  user_data = filebase64("${path.module}/promtheus.sh")
}
resource "aws_autoscaling_group" "autoscaling-prometheus" {
  desired_capacity = 2
  max_size         = 3
  min_size         = 2
  health_check_grace_period = 300
  health_check_type         = "ELB" // "EC2"
  launch_configuration      = aws_launch_configuration.prometheus.name
  vpc_zone_identifier       = data.aws_subnet_ids.private_subnet.ids
  target_group_arns         = module.alb-internal.target_group_arns
  lifecycle {
    create_before_destroy = true
  }
  tag {
    key = "Name"
    value = "prometheus-auto-scaling"
    propagate_at_launch = true
  }
}

module "sns" {
  source = "https://github.com/dzungda/aws-terraform-module/tree/master/terraform-aws-sns"
  alarms_email  = "hung.vumanh@vticloud.io"
}



resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale_up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "SimpleScaling"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.autoscaling-prometheus.name
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale_down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "SimpleScaling"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.autoscaling-prometheus.name
}
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "cpu_high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 3 //3 time
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60   //60 s
  statistic           = "Average"
  threshold           = 90 // 90%

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.autoscaling-prometheus.name
  }

  alarm_description = "Scale up if CPU utilization is above 90% for 60 seconds"
  alarm_actions     = [aws_autoscaling_policy.scale_up.arn, module.sns.sns_arn]
}
resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "cpu_low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 10

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.autoscaling-prometheus.name
  }

  alarm_description = "Scale down if CPU utilization is above 10% for 60 seconds"
  alarm_actions     = [/*aws_autoscaling_policy.scale_down.arn, module.sns.sns_arn]
}
*/