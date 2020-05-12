output "alb_dns_name" {
  value = module.alb.alb_dns_name
}
output "grafana_ip" {
  value = module.ec2.grafana-ip
}
output "prometheus-ip" {
  value = module.ec2.prometheus-ip
}
