locals {
  # Automatically load region-level variables

  subscription_vars  = read_terragrunt_config(find_in_parent_folders("subscription.hcl"))
  subscription_id       = local.subscription_vars.locals.subscription_id
 
}  

# Inject the remote backend configuration in all the modules that includes the root file without having to define them in the underlying modules 
remote_state {
  backend = "azurerm"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  # Store the terraform state files in a blob container located on an azure storage account
  config = {
    key                  = "${path_relative_to_include()}/terraform.tfstate"
    resource_group_name  = get_env("REMOTE_STATE_RESOURCE_GROUP", "test")
    storage_account_name = get_env("REMOTE_STATE_STORAGE_ACCOUNT", "ysegoeben")
    container_name       = get_env("REMOTE_STATE_STORAGE_CONTAINER", "tfstate")
  }
}

# Inject this provider configuration in all the modules that includes the root file without having to define them in the underlying modules
# This instructs Terragrunt to create the file provider.tf in the working directory (where Terragrunt calls terraform) before it calls any 
# of the Terraform commands (e.g plan, apply, validate, etc)
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "azurerm" {
  features {}
  subscription_id =  "${local.subscription_id}"
  client_id   = "04bb565b-e92f-45f0-8223-6fcea49345a7"
  client_secret       = "UJJ7Q~Tk1wX6LByjfWUvbrkmY3EL48WCBX.hN"
  tenant_id       = "5dd6d6f8-c5ac-40b5-b11b-568ff3e7ba8b"

  skip_provider_registration = true
}
EOF
}
generate "locals" {
  path      = "locals.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
locals {
  
  subscription_id       = "${local.subscription_id}"
 
}
EOF
}