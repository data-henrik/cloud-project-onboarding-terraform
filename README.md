# Terraform files for onboarding a cloud development project

The files in this repository are samples for the following IBM Cloud blog post:
[Blueprinting the Onboarding of Cloud Projects Using Terraform](https://www.ibm.com/cloud/blog/henrik-loeser).

They only provide a rough skeleton to demonstrate topics discussed in the blog. Only some of the files are provided which are required to deploy the full project. The IBM Cloud solution tutorial ["Apply end to end security to a cloud application"](https://cloud.ibm.com/docs/solution-tutorials?topic=solution-tutorials-cloud-e2e-security) is used as sample project or proof-point for the onboarding process.

### Structure
Terraform files are organized in directories and applied folder by folder, in ascending order.

- [000-base](000-base): Corporate base layer for all projects
- [010-account-admin](010-account-admin): Project-specific setup by the account owner or super admin
- [020-security-admin](020-security-admin):
- ...
- [040-app-services](040-app-services):
- ...