# retrieve resource group for workshop
data "ibm_resource_group" "workshop_rg" {
  name = "${var.projname}-workshop"
}

#
# Sample access group for showing setup
#
resource "ibm_iam_access_group" "sample_ag" {
  name        = "${var.projname}-AG-sample"
  description = "Sample access group with few permissions."
}


# view all IAM-enabled services in the resource group for the workshop
resource "ibm_iam_access_group_policy" "sample_ag-policy-rg-viewer" {
  access_group_id = ibm_iam_access_group.sample_ag.id
  roles           = ["Viewer", "Reader"]

  resources {
    resource_group_id = data.ibm_resource_group.workshop_rg.id
  }
}

# add users based on IdP who are students
resource "ibm_iam_access_group_dynamic_rule" "sample_ag-rule-students" {
  name              = "${var.projname}-student-rule"
  access_group_id   = ibm_iam_access_group.sample_ag.id
  expiration        = 1
  identity_provider = "appid://${var.idp-realm-id}"
  conditions {
    claim    = "workshop_roles"
    operator = "CONTAINS"
    value    = "student"
  }
}