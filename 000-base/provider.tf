terraform {
  required_version = ">= 0.15"
  required_providers {
    ibm = {
      source  = "ibm-cloud/ibm"
      version = "~>1.23.0"
    }
  }
}

provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
  generation       = 2
  ibmcloud_timeout = var.ibmcloud_timeout
}
