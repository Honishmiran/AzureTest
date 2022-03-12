terraform {
  source = "../../../../../terraform-azurerm-compute"
}
include {
  path = find_in_parent_folders()
}