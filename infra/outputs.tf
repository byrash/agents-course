output "server_ip" {
  description = "Public IPv4 address of the student's server"
  value       = hcloud_server.agent.ipv4_address
}

output "dashboard_url" {
  description = "ZeroClaw web dashboard URL"
  value       = "http://${hcloud_server.agent.ipv4_address}:42617"
}

output "ssh_command" {
  description = "SSH into the server as root"
  value       = "ssh root@${hcloud_server.agent.ipv4_address}"
}

output "ssh_zeroclaw" {
  description = "SSH into the server as zeroclaw user"
  value       = "ssh zeroclaw@${hcloud_server.agent.ipv4_address}"
}

output "student_name" {
  description = "Student name this server belongs to"
  value       = var.student_name
}

output "server_status" {
  description = "Server status"
  value       = hcloud_server.agent.status
}
