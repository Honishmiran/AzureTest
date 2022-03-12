vm_hostname = "windowstest"
resource_group_name = "test"
location = ""
vm_size = "Standard_D2s_v3"
identity_type = "SystemAssigned"
identity_ids = []
vm_custom_os_id = ""
is_windows_image = false
vm_os_simple = "WindowsServer"
license_type = "Windows_Server"
vm_os_publisher = "MicrosoftWindowsServer"
vm_os_offer = "WindowsServer"
vm_os_sku = "2016-Datacenter"
vm_os_version = "latest"
ssh_key = "public_key.pub"
enable_ssh_key = true
boot_diagnostics = true
boot_diagnostics_sa_uri = ""
os_profile_secrets = []
virtual_network_name = "test-vnet"
subnet_name = "mytest"
private_ip = "10.0.1.8"
source_address_prefixes = ["0.0.0.0/0"]
extra_disks = [
    {
    name = "1"
    size = 30
    lun = 0
    },
    {
    name = "2"
    size = 68
    lun = 1
    },
    {
    name = "3"
    size = 30
    lun = 2
    }
]  

tags = {
"Application "= "1"
"Application_code "= "2"
"Application_component "= "3"
"Application_Owner "= "4"
"Backup "= "5"
"Business hours "= "6"
"Business Impact "= "7"
"Company "= "8"
"Configuration "= "9"
"Cpu Count "= "1"
"Cpu Speed "= "2"
"Cpu Type "= "3"
"Environment "= "4"
"Fully Qualified Domain name "= "5"
"Installation Date "= "6"
"Ip Address "= "7"
"Location "= "8"
"Managed By  "= "9"
"Manufacturer "= "1"
"MONFRI1030AM0030AM "= "2"
"MONSUN06AM11PM "= "3"
"Month-15_to_30 "= "4"
"Name "= "5"
"Network_Tier "= "6"
"Operating system "= "7"
"Patching "= "8"
"Project "= "9"
"Ram "= "1"
"Support_Contact_Email "= "2"
"Team_Contact_Email "= "3"
"Termination_Date "= "4"
"Terraform "= "5"
"Version "= "6"
}