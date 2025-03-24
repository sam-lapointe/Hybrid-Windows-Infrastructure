# Windows Terraform Ansible
Project to apply what I learned while preparing for the AZ-800 certification (Administering Windows Server Hybrid Core Infrastructure) and practice with Terraform and Ansible.

## Setting up Terraform backend in Azure

1. Comment out the `backend` section in the `~/Windows-TerraformAnsible/Terraform/Setup/main.tf` file.
2. Execute the `~/Windows-TerraformAnsible/Terraform/Setup/init.sh` script on Ubuntu or Debian to create the Resource Group, Service Principal, and Storage Account in Azure.
3. In the `backend` section of the `~/Windows-TerraformAnsible/Terraform/Setup/main.tf` file, uncomment it and replace `storage_account_name` with your storage account name.
4. Initialize the backend and clean your local environement with these commands:

   ```sh
   source ~/.bashrc
   cd ~/Windows-TerraformAnsible/Terraform/Setup
   terraform init
   # Enter yes to migrate the existing state.
   rm terraform.tfstate terraform.tfstate.backup

