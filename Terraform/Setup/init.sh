#!/bin/bash

cd ~/Hybrid-Windows-Infrastructure/Terraform/Setup

# Function to detect the OS.
detect_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release # Source the OS release file

        if [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
            OS="debian_ubuntu"
        else
            echo "Unsupported OS: $ID. Only Ubuntu and Debian are supported in this script. You have to install az cli and jq manually."
            exit 1
        fi
    else
        echo "Could not determine the OS."
        exit 1
    fi
}

# Function to install Azure CLI
install_az_cli() {
    echo "Azure CLI is not installed. Installing..."

    # It is the same command on Debian and Ubuntu to install Azure CLI
    if [[ "$OS" == 'debian_ubuntu' ]]; then
        curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
    fi

    echo "Azure CLI installed successfully."
}

# Function to update Azure CLI
update_az_cli() {
    echo "Azure CLI is already installed. Updating..."

    # It is the same command on Debian and Ubuntu to update Azure CLI
    if [[ "$OS" == "debian_ubuntu" ]]; then
        sudo apt-get update && sudo apt-get install --only-upgrade -y azure-cli
    fi

    echo "Azure CLI updated successfully."
}

# Detect OS
detect_os

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    install_az_cli
else
    update_az_cli
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "jq is not installed. Installing..."
    sudo apt install jq
    echo "jq installed successfully."
else
    echo "jq is already installed. Updating..."
    sudo apt-get update && sudo apt-get install --only-upgrade -y jq
    echo "jq updated successfully."
fi

# Login with your user account using --use-device-code and select the subscription where you want to create the resource group.
az login --use-device-code
sub_id=$(az account show | jq -r .id)
export ARM_SUBSCRIPTION_ID=$sub_id

# Prompt the user for the location where the resource group and all of its resources will be deployed.
read -p "Enter the location: " location

# Create the resource group.
# The resource group name must also be changed in the vars.tf and main.tf if it is changed here.
rg_name="WindowsHybrid"
rg=$(az group create --name $rg_name --location $location)

# Create the service principal with the role Contributor on the resource group.
# Make sure to securely store the password.
service_principal=$(az ad sp create-for-rbac --name WindowsHybrid --role contributor --scopes /subscriptions/$sub_id/resourceGroups/$rg_name)

ARM_CLIENT_ID=$(echo $service_principal | jq -r .appId)
ARM_CLIENT_SECRET=$(echo $service_principal | jq -r .password)
ARM_TENANT_ID=$(echo $service_principal | jq -r .tenant)

# Export for current session
export ARM_CLIENT_ID ARM_CLIENT_SECRET ARM_TENANT_ID

# Persist for future session
echo "export ARM_CLIENT_ID=$ARM_CLIENT_ID" >> ~/.bashrc
echo "export ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET" >> ~/.bashrc
echo "export ARM_TENANT_ID=$ARM_TENANT_ID" >> ~/.bashrc
echo "export ARM_SUBSCRIPTION_ID=$sub_id" >> ~/.bashrc

sleep 2
echo "Terraform Initilisation..."
terraform init
# If there is no pause between each terraform call, it can cause authentication issues.
sleep 5
echo "Terraform Plan..."
terraform plan
# If there is no pause between each terraform call, it can cause authentication issues.
sleep 2
echo "Terraform Apply..."
terraform apply -auto-approve

sleep 5

# Get the name of the storage account created with Terraform. It should currently be the only storage account in this resource group.
storage_account_name=$(az storage account list --resource-group $rg_name --query "[0].name" --out tsv)

# Assign to the Service Principal the role Storage Blob Data Contributor on the Storage Account created with Terraform.
az role assignment create --assignee $ARM_CLIENT_ID --role "Storage Blob Data Contributor" --scope "/subscriptions/$sub_id/resourceGroups/$rg_name/providers/Microsoft.Storage/storageAccounts/$storage_account_name"

# Logout
az logout

# Remove the terraform.tfstate and terraform.tfstate.backup files
cd ~/Hybrid-Windows-Infrastructure/Terraform/Setup
rm -r .terraform
rm .terraform.lock.hcl