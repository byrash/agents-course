variable "hcloud_token" {
  description = "Hetzner Cloud API token (from parent's account)"
  type        = string
  sensitive   = true
}

variable "student_name" {
  description = "Student name (lowercase, no spaces — used for resource naming)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.student_name))
    error_message = "student_name must be lowercase alphanumeric with hyphens only."
  }
}

variable "server_type" {
  description = "Hetzner server type. cax11 = ARM 2vCPU/4GB ($4/mo), cpx11 = x86 2vCPU/2GB ($4.50/mo)"
  type        = string
  default     = "cax11"
}

variable "location" {
  description = "Hetzner data center: ash (Virginia), hil (Oregon), nbg1 (Germany), fsn1 (Germany), hel1 (Finland)"
  type        = string
  default     = "ash"
}

variable "os_image" {
  description = "Server OS image"
  type        = string
  default     = "ubuntu-24.04"
}

variable "telegram_bot_token" {
  description = "Telegram bot token from @BotFather"
  type        = string
  sensitive   = true
}

variable "telegram_user_id" {
  description = "Student's Telegram user ID (from @userinfobot)"
  type        = string
}

variable "llm_provider" {
  description = "LLM provider: openai, openrouter, copilot"
  type        = string
  default     = "openai"
}

variable "llm_model" {
  description = "LLM model name"
  type        = string
  default     = "gpt-4o"
}

variable "openai_api_key" {
  description = "OpenAI API key (required when llm_provider=openai)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "openrouter_api_key" {
  description = "OpenRouter API key (required when llm_provider=openrouter)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "zeroclaw_version" {
  description = "ZeroClaw release version tag"
  type        = string
  default     = "v0.3.0"
}

variable "instructor_ssh_public_key" {
  description = "Instructor's SSH public key for remote access (optional but recommended)"
  type        = string
  default     = ""
}
