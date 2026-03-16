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

output "student_private_key" {
  description = "Student's SSH private key (give this file to the student)"
  value       = tls_private_key.student.private_key_openssh
  sensitive   = true
}

output "student_ssh_config" {
  description = "SSH config block for the student to paste into ~/.ssh/config"
  value       = <<-EOT
    Host zc-${var.student_name}
      HostName ${hcloud_server.agent.ipv4_address}
      User zeroclaw
      IdentityFile ~/.ssh/zc-${var.student_name}
      StrictHostKeyChecking no
  EOT
}
