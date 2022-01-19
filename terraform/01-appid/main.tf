#
#

# define resource group for workshop
resource "ibm_resource_group" "workshop_rg" {
  name = "${var.projname}-workshop"
}


# App ID instance for workshop participants
resource "ibm_resource_instance" "WS_AppID" {
  name = "${var.projname}-WS-AppID"
  service           = "appid"
  plan              = "graduated-tier"
  location          = var.region
  resource_group_id = ibm_resource_group.workshop_rg.id
  service_endpoints = "public-and-private"
}

# enable auditing
resource "ibm_appid_audit_status" "status" {
  tenant_id = ibm_resource_instance.WS_AppID.guid
  is_active = true
}

# configure the cloud directory
resource "ibm_appid_idp_cloud_directory" "clouddirectory" {
  tenant_id = ibm_resource_instance.WS_AppID.guid
  is_active = true
  identity_field = "email"
  identity_confirm_access_mode = "OFF"
  self_service_enabled = false
  signup_enabled = false
  welcome_enabled = false
  reset_password_enabled = true
  reset_password_notification_enabled = true
}

# email templates
resource "ibm_appid_cloud_directory_template" "tpl_userverification" {
  tenant_id = ibm_resource_instance.WS_AppID.guid
  template_name = "USER_VERIFICATION"
  subject = "Please Verify Your Email Address %%{user.displayName}" // note: `%{` has to be escaped, otherwise it will be treated as terraform template directive
  plain_text_body = "Link: %%{verify.link} \nCode: %%{verify.code}"
  html_body = "Link: %%{verify.link} <br>Code: %%{verify.code}"
}

resource "ibm_appid_cloud_directory_template" "tpl_mfa" {
  tenant_id = ibm_resource_instance.WS_AppID.guid
  template_name = "MFA_VERIFICATION"
  subject = "One-time code for %%{user.displayName}" // note: `%{` has to be escaped, otherwise it will be treated as terraform template directive
  plain_text_body = "Please use this code to verify: %%{mfa.code}"
}

# turn off Facebook and Google
resource "ibm_appid_idp_facebook" "facebook" {
  tenant_id = ibm_resource_instance.WS_AppID.guid
  is_active = false
}

resource "ibm_appid_idp_google" "google" {
  tenant_id = ibm_resource_instance.WS_AppID.guid
  is_active = false
}


# map from additional attributes to token claims
resource "ibm_appid_token_config" "tokenconfig" {
  tenant_id = ibm_resource_instance.WS_AppID.guid
  anonymous_access_enabled = false

    id_token_claim {
    source = "attributes"
    source_claim = "workshop_roles"
    destination_claim = "workshop_roles"
  }
}

