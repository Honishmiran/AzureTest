module "os" {
  source       = "./os"
  vm_os_simple = var.vm_os_simple
}

data "azurerm_resource_group" "vm" {
  name = var.resource_group_name
}

locals {
  ssh_keys = compact(concat([var.ssh_key], var.extra_ssh_keys))
}

resource "azurerm_virtual_machine" "vm-linux" {
  count                            = !contains(tolist([var.vm_os_simple, var.vm_os_offer]), "WindowsServer") && !var.is_windows_image ? var.nb_instances : 0
  name                             = var.vm_hostname
  resource_group_name              = data.azurerm_resource_group.vm.name
  location                         = coalesce(var.location, data.azurerm_resource_group.vm.location)
  vm_size                          = var.vm_size
  network_interface_ids            = [azurerm_network_interface.vm.id]
  delete_os_disk_on_termination    = var.delete_os_disk_on_termination
  delete_data_disks_on_termination = var.delete_data_disks_on_termination

  dynamic "identity" {
    for_each = length(var.identity_ids) == 0 && var.identity_type == "SystemAssigned" ? [var.identity_type] : []
    content {
      type = var.identity_type
    }
  }

  dynamic "identity" {
    for_each = length(var.identity_ids) > 0 || var.identity_type == "UserAssigned" ? [var.identity_type] : []
    content {
      type         = var.identity_type
      identity_ids = length(var.identity_ids) > 0 ? var.identity_ids : []
    }
  }

  storage_image_reference {
    id        = var.vm_custom_os_id
    publisher = var.vm_custom_os_id == "" ? coalesce(var.vm_os_publisher, module.os.calculated_value_os_publisher) : ""
    offer     = var.vm_custom_os_id == "" ? coalesce(var.vm_os_offer, module.os.calculated_value_os_offer) : ""
    sku       = var.vm_custom_os_id == "" ? coalesce(var.vm_os_sku, module.os.calculated_value_os_sku) : ""
    version   = var.vm_custom_os_id == "" ? var.vm_os_version : ""
  }

  storage_os_disk {
    name              = "osdisk-${var.vm_hostname}"
    create_option     = "FromImage"
    caching           = "ReadWrite"
    managed_disk_type = var.os_disk_type
  }

  dynamic storage_data_disk {
    for_each = var.extra_disks
    content {
      name              = "${var.vm_hostname}-datadisk-${storage_data_disk.value.name}"
      create_option     = "Empty"
      lun               = storage_data_disk.key
      disk_size_gb      = storage_data_disk.value.size
      managed_disk_type = var.data_sa_type
    }
  }

  os_profile {
    computer_name  = var.vm_hostname
    admin_username = var.admin_username
    admin_password = var.admin_password
    custom_data    = var.custom_data
  }

  os_profile_linux_config {
    disable_password_authentication = var.enable_ssh_key

    dynamic "ssh_keys" {
      for_each = var.enable_ssh_key ? local.ssh_keys : []
      content {
        path     = "/home/${var.admin_username}/.ssh/authorized_keys"
        key_data = file(ssh_keys.value)
      }
    }

    dynamic "ssh_keys" {
      for_each = var.enable_ssh_key ? var.ssh_key_values : []
      content {
        path     = "/home/${var.admin_username}/.ssh/authorized_keys"
        key_data = ssh_keys.value
      }
    }

  }

  dynamic "os_profile_secrets" {
    for_each = var.os_profile_secrets
    content {
      source_vault_id = os_profile_secrets.value["source_vault_id"]

      vault_certificates {
        certificate_url = os_profile_secrets.value["certificate_url"]
      }
    }
  }

  tags = var.tags

  boot_diagnostics {
    enabled     = var.boot_diagnostics
    storage_uri = var.boot_diagnostics_sa_uri
  }
}

resource "azurerm_virtual_machine" "vm-windows" {
  count                         = (var.is_windows_image || contains(tolist([var.vm_os_simple, var.vm_os_offer]), "WindowsServer")) ? var.nb_instances : 0
  name                          = var.vm_hostname
  resource_group_name           = data.azurerm_resource_group.vm.name
  location                      = coalesce(var.location, data.azurerm_resource_group.vm.location)
  vm_size                       = var.vm_size
  network_interface_ids         = [azurerm_network_interface.vm.id]
  delete_os_disk_on_termination = var.delete_os_disk_on_termination
  license_type                  = var.license_type

  dynamic "identity" {
    for_each = length(var.identity_ids) == 0 && var.identity_type == "SystemAssigned" ? [var.identity_type] : []
    content {
      type = var.identity_type
    }
  }

  dynamic "identity" {
    for_each = length(var.identity_ids) > 0 || var.identity_type == "UserAssigned" ? [var.identity_type] : []
    content {
      type         = var.identity_type
      identity_ids = length(var.identity_ids) > 0 ? var.identity_ids : []
    }
  }

  storage_image_reference {
    id        = var.vm_custom_os_id
    publisher = var.vm_custom_os_id == "" ? coalesce(var.vm_os_publisher, module.os.calculated_value_os_publisher) : ""
    offer     = var.vm_custom_os_id == "" ? coalesce(var.vm_os_offer, module.os.calculated_value_os_offer) : ""
    sku       = var.vm_custom_os_id == "" ? coalesce(var.vm_os_sku, module.os.calculated_value_os_sku) : ""
    version   = var.vm_custom_os_id == "" ? var.vm_os_version : ""
  }

  storage_os_disk {
    name              = "osdisk-${var.vm_hostname}"
    create_option     = "FromImage"
    caching           = "ReadWrite"
    managed_disk_type = var.os_disk_type
  }


  os_profile {
    computer_name  = var.vm_hostname
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  tags = var.tags

  os_profile_windows_config {
    provision_vm_agent = true
  }

  dynamic "os_profile_secrets" {
    for_each = var.os_profile_secrets
    content {
      source_vault_id = os_profile_secrets.value["source_vault_id"]

      vault_certificates {
        certificate_url   = os_profile_secrets.value["certificate_url"]
        certificate_store = os_profile_secrets.value["certificate_store"]
      }
    }
  }
  # dynamic storage_data_disk {
  #   for_each = var.extra_disks
  #   content {
  #     name              = "${var.vm_hostname}-datadisk-${count.index}-${storage_data_disk.value.name}"
  #     create_option     = "Empty"
  #     lun               = storage_data_disk.key
  #     disk_size_gb      = storage_data_disk.value.size
  #     managed_disk_type = var.data_sa_type
  #   }
  # }


  boot_diagnostics {
    enabled     = var.boot_diagnostics
    storage_uri = var.boot_diagnostics_sa_uri
  }
}

resource "azurerm_managed_disk" "copy" {
  count = length(var.extra_disks)
  name                 = "${var.extra_disks.*.name[count.index]}"
  location             = "${!contains(tolist([var.vm_os_simple, var.vm_os_offer]), "WindowsServer") && !var.is_windows_image ? azurerm_virtual_machine.vm-linux[0].location : azurerm_virtual_machine.vm-windows[0].location}"
  resource_group_name  = "test"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  source_resource_id   = ""
  disk_size_gb         = var.extra_disks.*.size[count.index]

  tags = {
    environment = var.extra_disks.*.name[count.index]
  }
  depends_on = [
    azurerm_virtual_machine.vm-windows
    ]
  
}

resource "azurerm_virtual_machine_data_disk_attachment" "example" {
  count = length(var.extra_disks)   
  managed_disk_id    = "${azurerm_managed_disk.copy[count.index].id}"
  virtual_machine_id = "${!contains(tolist([var.vm_os_simple, var.vm_os_offer]), "WindowsServer") && !var.is_windows_image ? azurerm_virtual_machine.vm-linux[0].id : azurerm_virtual_machine.vm-windows[0].id }"
  lun                = var.extra_disks.*.lun[count.index]
  caching            = "ReadWrite"

  depends_on = [
    azurerm_virtual_machine.vm-windows
    ]
}


resource "azurerm_network_security_group" "vm" {
  name                = "${var.vm_hostname}-nsg"
  resource_group_name = data.azurerm_resource_group.vm.name
  location            = coalesce(var.location, data.azurerm_resource_group.vm.location)
}

resource "azurerm_network_interface" "vm" {
  name                          = "${var.vm_hostname}-nic"
  resource_group_name           = data.azurerm_resource_group.vm.name
  location                      = coalesce(var.location, data.azurerm_resource_group.vm.location)
  enable_accelerated_networking = var.enable_accelerated_networking

  ip_configuration {
    name                          = "${var.vm_hostname}-ip"
    subnet_id                     = "/subscriptions/${local.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.Network/virtualNetworks/${var.virtual_network_name}/subnets/${var.subnet_name}"
    private_ip_address_allocation = "Static"
    private_ip_address = var.private_ip
  }

}

resource "azurerm_network_interface_security_group_association" "test" {
  network_interface_id      = azurerm_network_interface.vm.id
  network_security_group_id = azurerm_network_security_group.vm.id
}

