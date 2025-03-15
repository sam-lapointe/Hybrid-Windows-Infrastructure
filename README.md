# Hybrid-Windows-Infrastructure
Project to apply what I learned while preparing for the AZ-800 certification (Administering Windows Server Hybrid Core Infrastructure).

## Setting up the Terraform backend in Azure

1. Comment out the `backend` section in the `~/Hybrid-Windows-Infrastructure/Terraform/Setup/main.tf` file.
2. Execute the `~/Hybrid-Windows-Infrastructure/Terraform/Setup/init.sh` script on Ubuntu or Debian to create the Resource Group, Service Principal, and Storage Account in Azure.
3. In the `backend` section of the `~/Hybrid-Windows-Infrastructure/Terraform/Setup/main.tf` file, uncomment it and replace `storage_account_name` with your storage account name.
4. Restart your shell and run:

   ```sh
   terraform init
