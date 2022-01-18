
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    ibm = {
      source  = "ibm-cloud/ibm"
      version = "~>1.34.0"
    }
  }
}

provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
  ibmcloud_timeout = var.ibmcloud_timeout
}