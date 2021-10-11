variable "environment_name" {
  type    = string
  default = "lacework-shift-left"
}

variable "owner_name" {
  type = string
}

variable "gcp_region" {
  type    = string
  default = "europe-west4"
}

variable "gcp_project" {
  type = string
}
variable "lacework_server_url" {
  type    = string
  default = "https://api.fra.lacework.net"
}

variable "app_name" {
  type    = string
  default = "lacework-shift-left-demo"
}
