variable "bucket_assets_name" {
  type    = string
  default = "tallyo-application-assets"
}

variable "tallyo_whatsapp_app_name" {
  type    = string
  default = "tallyo-whatsapp-app"
}

variable "tallyo_api_app_name" {
  type    = string
  default = "tallyo-api-app"
}

variable "incoming_messages_queue_name" {
  type    = string
  default = "tallyo-incoming-messages.fifo"
}

variable "message_processed_queue_name" {
  type    = string
  default = "tallyo-processed-messages.fifo"
}

variable "hosted_zone_name" {
  type    = string
  default = "platformoon.com"
}

variable "landing_page_domain" {
  type    = string
  default = "tallyo.platformoon.com"
}

variable "landing_page_deployer_name" {
  type    = string
  default = "tallyo-landing-page-gh-actions"
}
