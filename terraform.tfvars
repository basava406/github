resource_group_name = "myResourceGroup"  #"your-resource-group-name"
location            = "eastus2"  # Replace with your desired Azure region
vm_admin_username   = "chaitu"
public_key_path     =  "E:/terraform_1.4.6_windows_amd64/S0059_testpy/public_key.pub"
allowed_ssh_ip_address = ["49.206.48.95", "124.123.180.45"]  # Replace with your IP address and mask
vm_count           = 1  # Specify the desired number of VMs
prefix     = "git"  # Customize the prefix for resource names
