terraform {
  source = "../../../../../compute"
}
include {
  path = find_in_parent_folders()
}