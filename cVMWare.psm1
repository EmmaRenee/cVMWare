enum Ensure
{
    Absent
    Present
}

[DscResource()]
class VMWareResource
{
    [DscProperty(Mandatory)]
    [Ensure]$Ensure
    
    [DscProperty(Mandatory)]
    [string]$Name

    [DscProperty(Mandatory)]
    [string]$ResourcePool

    [DscProperty(Key)]
    [string]$Template

    [DscProperty(Mandatory)]
    [string]$vCenter

    [DscProperty(Mandatory]
    [PSCredential]$Credential

    [VMwareResource]Get()
    {       
        $this.OpenSession()
        
        $vm = Get-VM -Name $this.Name

        $this.CloseSession()

        If ($vm)
        {
            $this.Ensure = [Ensure]::Present
        }
        Else
        {
            $this.Ensure = [Ensure]::Absent
        }

        return $this
    }

    [bool] Test()
    {
        $this.OpenSession()

        $vm = Get-VM -Name $this.Name

        $this.CloseSession()

        If ($vm)
        {
            return $true
        }
        Else
        {
            return $false
        }
    }

    [void] Set()
    {
        $this.OpenSession()

        If ($this.Ensure -eq [Ensure]::Present)
        {
            If ($this.Template)
            {
                New-VM -Name $this.Name -Template $this.Template -ResourcePool $this.ResourcePool
            }
            Else
            {
                New-VM -Name $this.Name -ResourcePool $this.ResourcePool
            }
        }
        ElseIf ($this.Ensure -eq [Ensure]::Absent)
        {
            Remove-VM -VM $this.Name -DeletePermanently
        }

        $this.CloseSession()
    }

    [void] OpenSession()
    {
        Import-Module VMWare.PowerCLI

        Connect-VIServer -Server $this.vCenter -Credential $this.Credential
    }

    [void] CloseSession()
    {
        Disconnect-VIServer -Server $this.vCenter -Force
    }
}