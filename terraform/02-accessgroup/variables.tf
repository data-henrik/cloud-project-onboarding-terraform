variable "ibmcloud_api_key" {}

variable "region" {}

variable "ibmcloud_timeout" {
  description = "Timeout for API operations in seconds."
  default     = 900
}

variable "projname" {
  default = "cloudsec"
}

variable "idp-realm-id" {
  default = "replace-later"
}
