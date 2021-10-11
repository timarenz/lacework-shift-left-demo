output "app_external_ip" {
  value = kubernetes_service.app.status[0].load_balancer[0].ingress[0].ip
}
