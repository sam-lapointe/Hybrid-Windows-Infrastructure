## Create Proxmox Ubuntu VM templates
1. In Proxmox, create the template VM without using any media for the OS and any disk in Disks. We will be using a cloud image.
2. Add a CloudInit drive to the VM and configure the Cloud Init configuration such as the Username, Password, SSH Public Key and Network Config. Click on Regenerate Image when the Cloud Init configuration is completed.
3. Connect to the terminal of your Proxmox node and run the following commands:
   ```sh
   # Go to https://cloud-images.ubuntu.com/minimal/daily/jammy/ and get the link for the latest version of jammy-minimal-cloudimg-amd64.img
   wget https://cloud-images.ubuntu.com/minimal/daily/jammy/20250227/jammy-minimal-cloudimg-amd64.img
   # Replace 102 with your VM id
   qm set 102 --serial0 socket --vga serial0
   mv jammy-minimal-cloudimg-amd64.img ubuntu-2204.qcow2
   qemu-img resize ubuntu-2204.qcow2 32G
   # Replace DataStorage-01 with the name of your storage
   qm importdisk 102 ubuntu-2204.qcow2 DataStorage-01
4. In Proxmox go to the VM Hardware tab, select the Unused Disk 0, click on Edit, and finaly Add.
5. In Proxmox go to the VM Options tab and modify the boot order so the added disk is at #1 and enabled.
6. Connect to the VM and install the qemu-guest-agent with the following commands:
   ```sh
   sudo apt-get install qemu-guest-agent
   sudo systemctl start qemu-guest-agent
   sudo reboot
7. Once the VM rebooted, reconnect to the VM and execute the following commands:
   ```sh
   sudo cloud-init clean
   sudo rm -rf /etc/machine-id /var/lib/dbus/machine-id
   sudo touch /etc/machine-id
   ```
   If this step is not completed, all VMs cloned from this template will have the same MAC address on their NIC and if configured with DHCP, will receive the same IP address.
8. Shutdown the VM and Convert to Template.