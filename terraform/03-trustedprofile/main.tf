# retrieve resource group for workshop
data "ibm_resource_group" "workshop_rg" {
  name = "${var.projname}-workshop"
}


# define a Trusted Profile with a single policy and a dynamic rule
resource "ibm_iam_trusted_profile" "workshop_student_TP" {
  name="workshop_student"
  description="Trusted Profile for students in the workshop"
}

resource "ibm_iam_trusted_profile_claim_rule" "student_rule" {
  profile_id=ibm_iam_trusted_profile.workshop_student_TP.id
  name="${var.projname}-student"
  type      ="Profile-SAML"
  realm_name="appid://${var.idp-realm-id}"
  expiration= 7200
  conditions {
    claim="workshop_roles" 
    operator="CONTAINS"
    value="\"student\""
  }
}

resource "ibm_iam_trusted_profile_policy" "workshop_student-policy-rg-viewer" {
  profile_id=ibm_iam_trusted_profile.workshop_student_TP.id
  description="access policy for students"
  roles=["Viewer"]

  resources {
    resource_type = "resource-group"
    resource_group_id = data.ibm_resource_group.workshop_rg.id
    region = "eu-de"
  }
}