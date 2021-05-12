# "Blueprinting the onboarding of cloud projects using terraform"
# Sample terraform file
#
# Map each project phase to resource group

resource "ibm_resource_group" "development" {
  name = "${var.basename}-development"
  tags = []
}

resource "ibm_resource_group" "test" {
  name = "${var.basename}-test"
  tags = []
}


resource "ibm_resource_group" "production" {
  name = "${var.basename}-production"
  tags = []
}
