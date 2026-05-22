variable "region" {
  type        = string
  description = "AWS Region"
}

variable "ses_verify_domain" {
  type        = bool
  description = "If provided the module will create Route53 DNS records used for domain verification."
  default     = true
}

variable "ses_verify_dkim" {
  type        = bool
  description = "If provided the module will create Route53 DNS records used for DKIM verification."
  default     = true
}

variable "domain_template" {
  type        = string
  description = "The `format()` string to use to generate the base domain name for sending and receiving email with Amazon SES, `format(var.domain_template, var.tenant, var.environment, var.stage)"
}

variable "dns_delegated_environment_name" {
  type        = string
  default     = null
  description = "`dns-delegated` component environment name"
}

variable "zone_id" {
  type        = string
  default     = null
  description = "Route53 hosted zone ID. If provided, bypasses the `dns-delegated` remote state lookup."
}

variable "ssm_prefix" {
  type        = string
  default     = "/ses"
  sensitive   = false
  description = "The prefix to use for the SSM parameters"
}

variable "ses_user_enabled" {
  type        = bool
  description = "Creates user with permission to send emails from SES domain"
  default     = false
}

variable "ses_group_enabled" {
  type        = bool
  description = "Creates a group with permission to send emails from SES domain"
  default     = false
}

variable "custom_from_subdomain" {
  type        = list(string)
  description = "If provided the module will configure a custom MAIL FROM subdomain on the SES identity (e.g. `[\"bounce\"]` yields `bounce.<domain>`). Required for SPF/DMARC alignment when sending `From: addr@<domain>` — without it, SES uses `*.amazonses.com` as the envelope sender and many recipient filters (notably Microsoft EOP) score the mismatch as spam."
  default     = []
  nullable    = false
}

variable "custom_from_behavior_on_mx_failure" {
  type        = string
  description = "Behaviour of the custom MAIL FROM subdomain when its MX record is not found. One of `UseDefaultValue` or `RejectMessage`. Defaults to `UseDefaultValue` (SES falls back to its default `*.amazonses.com` envelope sender)."
  default     = "UseDefaultValue"

  validation {
    condition     = contains(["UseDefaultValue", "RejectMessage"], var.custom_from_behavior_on_mx_failure)
    error_message = "custom_from_behavior_on_mx_failure must be one of \"UseDefaultValue\" or \"RejectMessage\"."
  }
}

variable "custom_from_dns_record_enabled" {
  type        = bool
  description = "If enabled the module will create the Route53 MX record SES requires for the custom MAIL FROM subdomain. Disable if you manage the MX out-of-band."
  default     = true
}

variable "create_spf_record" {
  type        = bool
  description = "If true the module will create an SPF (TXT) record authorising `amazonses.com` to send. The underlying `cloudposse/terraform-aws-ses` module places this record on the MAIL FROM subdomain (`<custom_from_subdomain>.<domain>`) when `custom_from_subdomain` is set, and on the identity `domain` otherwise — i.e. always on the domain SPF is actually evaluated against (the envelope-sender / Return-Path domain). Recommended for DMARC compliance via SPF alignment."
  default     = false
}
