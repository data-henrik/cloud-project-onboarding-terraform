# "Blueprinting the onboarding of cloud projects using terraform"
# Sample terraform file
#
# Access Group "Organization Admins" (super user for account management)

# create the Access Group
resource "ibm_iam_access_group" "cloud-organization-admins" {
  name = "${var.basename}-organization-admins"
  description = "Organize the structure of the resources used by the organization."
}

# Account Management > All Account Management Services: Administrator
resource "ibm_iam_access_group_policy" "cloud-organization-admins-org_admin" {
  access_group_id = ibm_iam_access_group.cloud-organization-admins.id
  account_management = true
  roles = [ "Administrator" ]
}

# IAM services > All Identity and Access enabled services: Administrator, Manager
resource "ibm_iam_access_group_policy" "cloud-organization-admins-iam_admin" {
  access_group_id = ibm_iam_access_group.cloud-organization-admins.id
  roles = [ "Administrator", "Manager" ]
}

# Account Management > Support Center: Editor
resource "ibm_iam_access_group_policy" "cloud-organization-admins-support" {
  access_group_id = ibm_iam_access_group.cloud-organization-admins.id
  roles = [ "Editor" ]
  resources {
    service = "support"
  }
}

# Account Management > Security & Compliance Center: Administrator
resource "ibm_iam_access_group_policy" "cloud-organization-admins-scc" {
  access_group_id = ibm_iam_access_group.cloud-organization-admins.id
  roles = [ "Administrator"]
  resources {
    service = "compliance"
  }
}