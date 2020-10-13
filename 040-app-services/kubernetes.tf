# # Provision Kubernetes cluster in VPC
resource "ibm_container_vpc_cluster" "cluster" {

  name              = "${var.basename}-cluster"
  vpc_id            = data.ibm_is_vpc.sfsvpc.id
  flavor            = var.iks_machine_type
  worker_count      = var.iks_worker_count
  resource_group_id = data.ibm_resource_group.cloud_development.id
  kube_version      = var.iks_version
  wait_till         = var.iks_wait_till

  zones {
    subnet_id = data.ibm_is_vpc.sfsvpc.subnets[0].id
    name      = "${var.region}-1"
  }
  zones {
    subnet_id = data.ibm_is_vpc.sfsvpc.subnets[1].id
    name      = "${var.region}-2"
  }
  zones {
    subnet_id = data.ibm_is_vpc.sfsvpc.subnets[2].id
    name      = "${var.region}-3"
  }
}

# Bind the App ID service to the cluster
resource "ibm_container_bind_service" "bind_appid" {
  cluster_name_id       = ibm_container_vpc_cluster.cluster.id
  service_instance_name = ibm_resource_instance.app_id.name
  resource_group_id     = data.ibm_resource_group.cloud_development.id
  key                   = ibm_resource_key.RKappid.name
  namespace_id          = kubernetes_namespace.namespace.metadata.0.name
}


# Download the cluster configuration...
data "ibm_container_cluster_config" "mycluster" {
  cluster_name_id   = ibm_container_vpc_cluster.cluster.name
  resource_group_id = data.ibm_resource_group.cloud_development.id
}

# ... and apply it to configure the Kubernetes provider
provider "kubernetes" {
  load_config_file       = "false"
  host                   = data.ibm_container_cluster_config.mycluster.host
  token                  = data.ibm_container_cluster_config.mycluster.token
  cluster_ca_certificate = data.ibm_container_cluster_config.mycluster.ca_certificate
  version                = "~> 1.12"
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.iks_namespace
  }
}

# Create new secret with app configuration which the app container will consume
resource "kubernetes_secret" "appsecrets" {
  metadata {
    name      = "${var.basename}-credentials"
    namespace = kubernetes_namespace.namespace.metadata.0.name
  }

  data = {
    cos_endpoint           = var.cos_endpoint
    cos_ibmAuthEndpoint    = var.cos_ibmAuthEndpoint
    cos_apiKey             = ibm_resource_key.RKcos.credentials.apikey
    cos_resourceInstanceId = ibm_resource_key.RKcos.credentials.resource_instance_id
    cos_access_key_id      = ibm_resource_key.RKcos.credentials["cos_hmac_keys.access_key_id"]
    cos_secret_access_key  = ibm_resource_key.RKcos.credentials["cos_hmac_keys.secret_access_key"]
    cos_bucket_name        = ibm_cos_bucket.cosbucket.bucket_name
    cloudant_username      = ibm_resource_key.RKcloudant.credentials.username
    cloudant_iam_apikey    = ibm_resource_key.RKcloudant.credentials.apikey
    cloudant_database      = "${var.basename}-metadata"
  }
}
