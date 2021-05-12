# "Blueprinting the onboarding of cloud projects using terraform"
# Sample terraform file
#
# Deploy as account owner or super admin


# Obtain IAM authentication token
data "ibm_iam_auth_token" "iam_tokendata" {}

# Obtain references to existing Access Groups
data "ibm_iam_access_group" "cloud_org_admins" {
  access_group_name = "${var.basename}-organization-admins"
}
data "ibm_iam_access_group" "cloud-security-admins" {
  access_group_name = "${var.basename}-security-admins"
}


# Reference to resource group "cloud-development"
# Needed only if scoping privileges or actions to a resource group
data "ibm_resource_group" "cloud_development" {
  name = "${var.basename}-development"
}

# Section to define IAM service IDs
#
# The service IDs are part of the related access group 
# and are used to perform the rollout

# Create a service ID for security resources
resource "ibm_iam_service_id" "securityServiceID" {
  name        = "${var.basename}-SecurityServiceID"
  description = "ServiceID for deploying security resources"

}

# create and download API key
# Terraform resource
resource "ibm_iam_service_api_key" "securityServiceID-apiKey" {
  name = "${var.basename}-SecurityServiceID-apiKey"
  iam_service_id = ibm_iam_service_id.securityServiceID.iam_id
  store_value = true
  file = "${var.basename}-SecurityServiceID-key.json"
}


# Create a service ID for devOps tasks
resource "ibm_iam_service_id" "devopsServiceID" {
  name        = "${var.basename}-DevopsServiceID"
  description = "ServiceID for deploying the app and devops tasks"

  # create and download API key
  # This example uses a loca executioner and the API
  provisioner "local-exec" {
    command = "curl -X POST 'https://iam.cloud.ibm.com/v1/apikeys' -H 'Authorization: ${data.ibm_iam_auth_token.iam_tokendata.iam_access_token}' -H 'Content-Type: application/json' -d '{ \"name\":\"${var.basename}-DevopsServiceID-key\", \"iam_id\":\"${ibm_iam_service_id.devopsServiceID.iam_id}\", \"store_value\": true}' > ${var.basename}-DevopsServiceID-key.json"
  }
}



#
# Now invite the (sample) users...
#

resource "ibm_iam_user_invite" "invite_user" {
  users = [
    var.user_org_admin
  ]
}

#
# ... and add them to the Access Groups
#

resource "ibm_iam_access_group_members" "cloud-org-admin-members" {
  access_group_id = data.ibm_iam_access_group.cloud_org_admins.groups[0].id
  ibm_ids = [
    var.user_org_admin
  ]
  depends_on = [ibm_iam_user_invite.invite_user]
}

