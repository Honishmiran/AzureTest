

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
    storage_account_name = get_env("REMOTE_STATE_STORAGE_ACCOUNT", "tsushistatetf")
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
  skip_provider_registration = true
}
EOF
}
