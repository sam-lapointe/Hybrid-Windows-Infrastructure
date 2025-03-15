## Create Proxmox Windows VM templates
1. Upload Windows Server 2025 and virtio-win ISOs to Proxmox
2. Create 2 VM with basic configuration in Proxmox with the ISOs uploaded previously.
3. On one VM select the Desktop Experience and the other Core.
4. Start the Windows Server Setup and install the following drivers:
    - Balloon\2k25\amd64\balloon.inf
    - NetKVM\2k25\amd64\netkvm.inf
    - vioscsi\2k25\amd64\vioscsi.inf
5. Install Windows Server
6. Install the QEMU Agent and Drivers:
   ```sh
   msiexec.exe /i "D:\guest-agent\qemu-ga-x86_64.msi" /quiet
   msiexec.exe /i "D:\virtio-win-gt-x64.msi" /qn
   Restart-Computer -Force
7. Configure SSH
   ```sh
   New-NetFirewallRule -DisplayName 'Allow SSH' -Name 'Allow SSH' -Profile Any -LocalPort 22 -Protocol TCP
   Set-Service -Name sshd -StartupType Automatic -Status Running
   Set-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH\" -Name "DefaultShell" -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
8. On your local machine create a xml file with this content:
   ```xml
   <unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="oobeSystem">
        <component name="Microsoft-Windows-International-Core" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
            <InputLocale>en-US</InputLocale> 
            <SystemLocale>en-CA</SystemLocale> 
            <UILanguage>en-US</UILanguage> 
            <UserLocale>en-CA</UserLocale>
            <UILanguageFallback>en-US</UILanguageFallback>
        </component>

        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
            <OOBE>
                <HideEULAPage>true</HideEULAPage>
                <HideLocalAccountScreen>true</HideLocalAccountScreen>
                <HideOEMRegistrationScreen>true</HideOEMRegistrationScreen>
                <HideOnlineAccountScreens>true</HideOnlineAccountScreens>
                <HideWirelessSetupInOOBE>true</HideWirelessSetupInOOBE>
                <NetworkLocation>Work</NetworkLocation>
                <SkipMachineOOBE>true</SkipMachineOOBE>
                <SkipUserOOBE>true</SkipUserOOBE>
            </OOBE>
            <UserAccounts>
                <AdministratorPassword>
                    <Value>TemporaryPassword123!</Value>
                    <PlainText>true</PlainText>
                </AdministratorPassword>
            </UserAccounts>
        </component>
    </settings>
   </unattend>
   ```
   Note that the Administrator's password need to be changed every time a new VM will be created with a template. You shouldn't put a used password in this file since it is in plain text or encoded.
9. Transfer the Unattend.xml file with SSH
   ```sh
   scp \path\to\Unattend.xml administrator@ip:C:\Unattend.xml
10. Sysprep the image:
    ```sh
    C:\Windows\System32\Sysprep\sysprep.exe /generalize /oobe /shutdown /unattend:"C:\Unattend.xml"
    ```
    When Sysprep is completed the VM will automatically shutdown.
11. In Proxmox, convert the VM to template.