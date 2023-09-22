# "Blueprinting the onboarding of cloud projects using terraform"
# Sample terraform file
#
# Access Group "Security Admins"


# create the Access Group
resource "ibm_iam_access_group" "cloud-security-admins" {
  name = "${var.basename}-security-admins"
  description = "Establish and manage security policies for the entire organization, including access management and organization constraint policies."
}

# IAM services > Functions: Viewer, Reader
resource "ibm_iam_access_group_policy" "cloud-security-admins-functions" {
  access_group_id = ibm_iam_access_group.cloud-security-admins.id
  roles = [ "Reader", "Viewer" ]
  resources {
    service = "functions"
  }
}

# IAM services > IAM Identity Service: Administrator, Viewer
resource "ibm_iam_access_group_policy" "cloud-security-admins-iam" {
  access_group_id = ibm_iam_access_group.cloud-security-admins.id
  roles = [ "Administrator", "Viewer" ]
  resources {
    service = "iam-identity"
  }
}

# IAM services > LogDNA: Reader, Viewer, Standard Member
resource "ibm_iam_access_group_policy" "cloud-security-admins-logdna" {
  access_group_id = ibm_iam_access_group.cloud-security-admins.id
  roles = [ "Reader", "Viewer", "Standard Member" ]
  resources {
    service = "logdna"
  }
}

# IAM services > Security Advisor: Administrator, Manager
resource "ibm_iam_access_group_policy" "cloud-security-admins-secadvisor" {
  access_group_id = ibm_iam_access_group.cloud-security-admins.id
  roles = [ "Administrator", "Manager" ]
  resources {
    service = "security-advisor"
  }
}

# IAM services > IAM Access Groups: Administrator
resource "ibm_iam_access_group_policy" "cloud-security-admins-groups" {
  access_group_id = ibm_iam_access_group.cloud-security-admins.id
  roles = [ "Administrator" ]
  resources {
    service = "iam-groups"
  }
}

# IAM services > Kubernetes Service: Viewer, Reader
resource "ibm_iam_access_group_policy" "cloud-security-admins-kube" {
  access_group_id = ibm_iam_access_group.cloud-security-admins.id
  roles = [ "Reader", "Viewer" ]
  resources {
    service = "containers-kubernetes"
  }
}

# IAM services > All resources in account (including future IAM enabled services): Viewer
resource "ibm_iam_access_group_policy" "cloud-security-admins-viewall" {
  access_group_id = ibm_iam_access_group.cloud-security-admins.id
  roles = [ "Viewer"]
}

# IAM services > All IAM-enabled services / resources in resource groups: Viewer, Reader, Editor
resource "ibm_iam_access_group_policy" "cloud-security-admins-viewall-rg" {
  access_group_id = ibm_iam_access_group.cloud-security-admins.id
  roles = [ "Viewer", "Reader", "Editor" ]
    resources {
    resource_type = "resource-group"
  }
}

# Account Management > Support Center: Editor
resource "ibm_iam_access_group_policy" "cloud-security-admins-support" {
  access_group_id = ibm_iam_access_group.cloud-security-admins.id
  roles = [ "Editor" ]
  resources {
    service = "support"
  }
}

# Account Management > Security & Compliance Center: Administrator
resource "ibm_iam_access_group_policy" "cloud-security-admins-scc" {
  access_group_id = ibm_iam_access_group.cloud-security-admins.id
  roles = [ "Administrator" ]
  resources {
    service = "compliance"
  }
}


# Account Manager > All account management services: Viewer
# To track all user-specific authorizations
resource "ibm_iam_access_group_policy" "cloud-security-admins-org_viewer" {
  access_group_id = ibm_iam_access_group.cloud-security-admins.id
  account_management = true
  roles = [ "Viewer" ]
}
