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
data "ibm_iam_access_group" "cloud-network-admins" {
  access_group_name = "${var.basename}-network-admins"
}
data "ibm_iam_access_group" "cloud-security-admins" {
  access_group_name = "${var.basename}-security-admins"
}
data "ibm_iam_access_group" "cloud-devops" {
  access_group_name = "${var.basename}-devops"
}
data "ibm_iam_access_group" "cloud_devs" {
  access_group_name = "${var.basename}-developers"
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

  # create and download API key
  provisioner "local-exec" {
    command = "curl -X POST 'https://iam.cloud.ibm.com/v1/apikeys' -H 'Authorization: ${data.ibm_iam_auth_token.iam_tokendata.iam_access_token}' -H 'Content-Type: application/json' -d '{ \"name\":\"${var.basename}-SecurityServiceID-key\", \"iam_id\":\"${ibm_iam_service_id.securityServiceID.iam_id}\", \"store_value\": true}' > ${var.basename}-SecurityServiceID-key.json"
  }

}

# Create a service ID for devOps tasks
resource "ibm_iam_service_id" "devopsServiceID" {
  name        = "${var.basename}-DevopsServiceID"
  description = "ServiceID for deploying the app and devops tasks"

  # create and download API key
  provisioner "local-exec" {
    command = "curl -X POST 'https://iam.cloud.ibm.com/v1/apikeys' -H 'Authorization: ${data.ibm_iam_auth_token.iam_tokendata.iam_access_token}' -H 'Content-Type: application/json' -d '{ \"name\":\"${var.basename}-DevopsServiceID-key\", \"iam_id\":\"${ibm_iam_service_id.devopsServiceID.iam_id}\", \"store_value\": true}' > ${var.basename}-DevopsServiceID-key.json"
  }
}


# Create a service ID to deploy network resources
resource "ibm_iam_service_id" "networkServiceID" {
  name        = "${var.basename}-NetworkServiceID"
  description = "ServiceID for deploying network resources"

  # create and download API key
  provisioner "local-exec" {
    command = "curl -X POST 'https://iam.cloud.ibm.com/v1/apikeys' -H 'Authorization: ${data.ibm_iam_auth_token.iam_tokendata.iam_access_token}' -H 'Content-Type: application/json' -d '{ \"name\":\"${var.basename}-NetworkServiceID-key\", \"iam_id\":\"${ibm_iam_service_id.networkServiceID.iam_id}\", \"store_value\": true}' > ${var.basename}-NetworkServiceID-key.json"
  }
}

# Create a service ID to deploy app-specific resources and services
resource "ibm_iam_service_id" "appServiceID" {
  name        = "${var.basename}-AppServiceID"
  description = "ServiceID for holding app resources"

  # create and download API key
  provisioner "local-exec" {
    command = "curl -X POST 'https://iam.cloud.ibm.com/v1/apikeys' -H 'Authorization: ${data.ibm_iam_auth_token.iam_tokendata.iam_access_token}' -H 'Content-Type: application/json' -d '{ \"name\":\"${var.basename}-AppServiceID-key\", \"iam_id\":\"${ibm_iam_service_id.appServiceID.iam_id}\", \"store_value\": true}' > ${var.basename}-AppServiceID-key.json"
  }
}


#
# Now invite the (sample) users...
#

resource "ibm_iam_user_invite" "invite_user" {
  users = [
    var.user_org_admin,
    var.user_network_admin,
    var.user_devops,
    var.user_security_admin,
    var.user_dev
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

resource "ibm_iam_access_group_members" "cloud-network-admin-members" {
  access_group_id = data.ibm_iam_access_group.cloud-network-admins.groups[0].id
  ibm_ids = [
    var.user_network_admin
  ]
  iam_service_ids = [ibm_iam_service_id.networkServiceID.id]
  depends_on      = [ibm_iam_user_invite.invite_user]
}

resource "ibm_iam_access_group_members" "cloud-devops-members" {
  access_group_id = data.ibm_iam_access_group.cloud-devops.groups[0].id
  ibm_ids = [
    var.user_devops
  ]
  iam_service_ids = [ibm_iam_service_id.devopsServiceID.id]
  depends_on      = [ibm_iam_user_invite.invite_user]
}


resource "ibm_iam_access_group_members" "cloud-developers-members" {
  access_group_id = data.ibm_iam_access_group.cloud_devs.groups[0].id
  ibm_ids         = [var.user_dev]
  depends_on      = [ibm_iam_user_invite.invite_user]
}

resource "ibm_iam_access_group_members" "cloud-security-admin-members" {
  access_group_id = data.ibm_iam_access_group.cloud-security-admins.groups[0].id
  ibm_ids = [
    var.user_security_admin
  ]
  iam_service_ids = [ibm_iam_service_id.securityServiceID.id]
  depends_on      = [ibm_iam_user_invite.invite_user]
}

resource "ibm_iam_access_group_members" "cloud-app-services-members" {
  access_group_id = ibm_iam_access_group.cloud-app-services.id
  iam_service_ids = [ibm_iam_service_id.appServiceID.id]
}
