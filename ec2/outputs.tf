output "prometheus-ids" {
  value = aws_instance.prometheus.*.id
}
output "grafana-id" {
  value = aws_instance.grafana.*.id
}
output "grafana-ip" {
  value = aws_instance.grafana.*.public_ip
}
output "prometheus-ip" {
  value = aws_instance.prometheus.*.private_ip
}
