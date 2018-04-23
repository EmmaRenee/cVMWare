enum Ensure 
{
   Absent
   Present
}

Configuration TestVMDeploy 
{    
    Param (
        [Parameter(Mandatory=$true)]
        $Credential
    )
    Import-DscResource -ModuleName cVMWare

    Node $AllNodes.where({$_.Task -eq 'NewVMs'}).NodeName 
    {
        $vms = $ConfigurationData.NonNodeData.Tasks.($Node.Task)
        Foreach ($vm in $vms)
        {
            #VM $vm.VMName 
            NewVM $vm.VMName
            {
                Ensure             = [Ensure]::Present
                Name               = $vm.VMName
                vCenter            = $vm.vCenter
                Template           = $vm.VMTemplate
                Location           = $vm.Location
                ResourcePool       = $vm.Cluster
                vCenterCredential  = $Credential
            }

            StartVM $vm.VMName
            {
                Name               = $vm.VMName
                vCenter            = $vm.vCenter
                vCenterCredential  = $Credential
            }
        }
    }
}

Import-Module VMware.PowerCLI -Force

# This module is dependant on PowerCLI and need to be run on a system which has this module installed.
# To install PowerCLI run:
# > Install-Module VMWare.PowerCLI

# Provide the hostname of your authoring machine. This is the machine with PowerCLI
$AuthoringMachine = '[provide-system]'

# Provide the hostname of your Pull Server.
$pullserver = '[provide-pullserver]'

TestVMDeploy -ConfigurationData .\ConfigData3.psd1 -OutputPath .\ -Credential $(Get-Credential -Message 'Enter vCenter Credentials')

$guid = Get-DscLocalConfigurationManager -CimSession $AuthoringMachine | Select-Object -ExpandProperty ConfigurationID
$target = "\\$pullserver\c$\program files\windowspowershell\DscService\Configuration\$Guid.mof"

Copy-Item -Path ".\$AuthoringMachine.mof" -Destination $target -Force

New-DSCCheckSum $target -Force