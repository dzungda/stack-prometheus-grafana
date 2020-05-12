output "alb_dns_name" {
  value = "${aws_lb.stack_monitor.dns_name}"
}

output "target_group_arn" {
  value = "${aws_lb_target_group.stack_monitor.arn}"
}
output "alb_zone_id" {
  value = "${aws_lb.stack_monitor.zone_id}"
}
