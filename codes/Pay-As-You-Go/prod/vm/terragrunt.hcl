locals{
    service = "Virtual Machine"
}
terraform {
  source = "../../../../modules/compute"
}
include {
  path = find_in_parent_folders()
}