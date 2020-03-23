# terraform cloud

## Login terraform-cloud for CLI
cf. https://developer.hashicorp.com/terraform/cli/commands/login

```bash
# Because the cloud block is not supported by older versions of Terraform, you must use 1.1.0 or higher in order to follow this tutorial.
tfenv use 1.4.5

# app.terraform.io = terraform-cloud host
terraform login app.terraform.io
```

## Import Resources
cf. https://support.hashicorp.com/hc/en-us/articles/360061289934-How-to-Import-Resources-into-a-Remote-State-Managed-by-Terraform-Cloud

Login terraform-cloud, then use terraform-import command.
```bash
terraform login app.terraform.io
terraform import xxxx.yyyy zzzz
```

## Setup GCP Credentials for terraform-cloud
cf. https://support.hashicorp.com/hc/en-us/articles/4406586874387-How-to-set-up-Google-Cloud-GCP-credentials-in-Terraform-Cloud

Created `terraform-cloud` gcp service-account credentials as `GOOGLE_CREDENTIALS` env in terraform-cloud.
