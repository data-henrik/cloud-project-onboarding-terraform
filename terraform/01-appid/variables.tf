variable "ibmcloud_api_key" {}

variable "region" {}

variable "projname" {
  default = "cloudsec"
}

# not needed in this module but included to remove warning
variable "idp-realm-id" {
  default = "replace-later"
}