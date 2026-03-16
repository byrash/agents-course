resource "tls_private_key" "student" {
  algorithm = "ED25519"
}

resource "hcloud_ssh_key" "student" {
  name       = "student-${var.student_name}"
  public_key = tls_private_key.student.public_key_openssh
}

resource "hcloud_ssh_key" "instructor" {
  count      = var.instructor_ssh_public_key != "" ? 1 : 0
  name       = "instructor-${var.student_name}"
  public_key = var.instructor_ssh_public_key
}

resource "hcloud_firewall" "agent" {
  name = "zc-${var.student_name}"

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "22"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  # ZeroClaw web dashboard
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "42617"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  rule {
    direction       = "out"
    protocol        = "tcp"
    port            = "any"
    destination_ips = ["0.0.0.0/0", "::/0"]
  }

  rule {
    direction       = "out"
    protocol        = "udp"
    port            = "any"
    destination_ips = ["0.0.0.0/0", "::/0"]
  }
}

resource "hcloud_server" "agent" {
  name        = "zc-${var.student_name}"
  server_type = var.server_type
  location    = var.location
  image       = var.os_image

  ssh_keys = concat(
    [hcloud_ssh_key.student.id],
    var.instructor_ssh_public_key != "" ? [hcloud_ssh_key.instructor[0].id] : []
  )
  firewall_ids = [hcloud_firewall.agent.id]

  user_data = templatefile("${path.module}/cloud-init.yaml.tpl", {
    student_name        = var.student_name
    telegram_bot_token  = var.telegram_bot_token
    telegram_user_id    = var.telegram_user_id
    llm_provider        = var.llm_provider
    llm_model           = var.llm_model
    openai_api_key      = var.openai_api_key
    openrouter_api_key  = var.openrouter_api_key
    zeroclaw_version    = var.zeroclaw_version

    student_ssh_pubkey = tls_private_key.student.public_key_openssh

    ws_agents   = file("${path.module}/../workspace-defaults/AGENTS.md")
    ws_soul     = file("${path.module}/../workspace-defaults/SOUL.md")
    ws_identity = replace(
      file("${path.module}/../workspace-defaults/IDENTITY.md"),
      "**Name:** Assistant",
      "**Name:** ${var.student_name}'s Agent"
    )
    ws_user  = file("${path.module}/../workspace-defaults/USER.md")
    ws_tools = file("${path.module}/../workspace-defaults/TOOLS.md")
  })

  labels = {
    course  = "ai-agents"
    student = var.student_name
  }

  lifecycle {
    ignore_changes = [user_data]
  }
}
