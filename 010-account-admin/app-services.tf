# "Blueprinting the onboarding of cloud projects using terraform"
# Sample terraform file
#
# Access group to manage application resources for sample scenario
# https://cloud.ibm.com/docs/solution-tutorials?topic=solution-tutorials-cloud-e2e-security

# Access group for managing app resources, mostly through a service ID
resource "ibm_iam_access_group" "cloud-app-services" {
  name        = "${var.basename}-app-services"
  description = "Create app-related resources and services, mostly through a service ID."
}

# IAM services > Kubernetes Service: Administrator, Manager, Writer, Viewer
resource "ibm_iam_access_group_policy" "cloud-app-services-kube" {
  access_group_id = ibm_iam_access_group.cloud-app-services.id
  roles           = ["Administrator", "Manager", "Writer", "Viewer"]
  resources {
    service           = "containers-kubernetes"
  }
}


# IAM services > All IAM-enabled services / resources in resource groups: Viewer, Reader, Editor
resource "ibm_iam_access_group_policy" "cloud-app-services-viewall-rg" {
  access_group_id = ibm_iam_access_group.cloud-app-services.id
  roles           = ["Viewer", "Reader", "Editor"]
  resources {
    resource_type = "resource-group"
  }
}

# IAM services > Infrastructure Service > All Resource Types: Viewer for account
resource "ibm_iam_access_group_policy" "cloud-app-services-vpc" {
  access_group_id = ibm_iam_access_group.cloud-app-services.id
  roles           = ["Viewer"]
  resources {
    service = "is"
  }
}


# IAM services > Key Protect: Manager, Writer
# Manager is needed to delete keys
resource "ibm_iam_access_group_policy" "cloud-app-services-kms" {
  access_group_id = ibm_iam_access_group.cloud-app-services.id
  roles           = ["Manager","Writer"]
  resources {
    # Use something like the line below to scope privileges to specific
    # resource groups.
    
    # resource_group_id = data.ibm_resource_group.cloud_development.id
    service           = "kms"
  }
}

# IAM services > Cloud Object Storage: Writer
resource "ibm_iam_access_group_policy" "cloud-app-services-cos" {
  access_group_id = ibm_iam_access_group.cloud-app-services.id
  roles           = ["Writer"]
  resources {
    service           = "cloud-object-storage"
  }
}

# IAM services > AppID: Writer
resource "ibm_iam_access_group_policy" "cloud-app-services-appid" {
  access_group_id = ibm_iam_access_group.cloud-app-services.id
  roles           = ["Writer"]
  resources {
    service           = "appid"
  }
}

# IAM services > Cloudant: Manager
# Manager is needed to create a database
resource "ibm_iam_access_group_policy" "cloud-app-services-cloudant" {
  access_group_id = ibm_iam_access_group.cloud-app-services.id
  roles           = ["Manager"]
  resources {
    service           = "cloudantnosqldb"
  }
}
