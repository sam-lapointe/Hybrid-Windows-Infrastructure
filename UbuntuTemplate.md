## Create Proxmox Ubuntu VM templates
1. In Proxmox, create the template VM without using any media for the OS and any disk in Disks. We will be using a cloud image.
2. Add a CloudInit drive to the VM and configure the Cloud Init configuration such as the Username, Password, SSH Public Key and Network Config. Click on Regenerate Image when the Cloud Init configuration is completed.
3. 