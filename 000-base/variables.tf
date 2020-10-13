# Hold the API key
variable "ibmcloud_api_key" {
}

# Deployment region, default is "us-south"
variable "region" {
  default = "us-south"
}

variable "ibmcloud_timeout" {
  description = "Timeout for API operations in seconds."
  default     = 900
}

# Project basename
variable "basename" {
  default = "cloud"
}