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

# Define variables for the app, VPC, Kubernetes, etc.
variable "iks_namespace" {
  default = "prod"
}

variable "iks_machine_type" {
  default = "bx2.4x16"
}

variable "iks_worker_count" {
  default = 1
}

variable "iks_version" {
  default = "1.17.11"
}

variable "iks_wait_till" {
  default = "OneWorkerNodeReady"
}

variable "cos_endpoint" {
  default = "s3.direct.us-south.cloud-object-storage.appdomain.cloud"
}

variable "cos_ibmAuthEndpoint" {
  default = "https://iam.cloud.ibm.com/oidc/token"
}
