enum Ensure
{
    Absent
    Present
}

[DscResource()]
class NewVM
{
    [DscProperty(Mandatory)]
    [Ensure]$Ensure
    
    [DscProperty(Key)]
    [string]$Name

    [DscProperty(Mandatory)]
    [string]$ResourcePool

    [DscProperty(Key)]
    [string]$Template

    [DscProperty(key)]
    [string]$Location

    [DscProperty(Mandatory)]
    [string]$vCenter

    [DscProperty(Mandatory)]
    [PSCredential]$vCenterCredential

    [DscProperty(NotConfigurable)]
    [bool]$Present

    [NewVM] Get()
    {       
        $this.OpenSession()
        
        $vm = Get-VM -Name $this.Name -ErrorAction SilentlyContinue

        $this.CloseSession()

        If ($vm)
        {
            $this.Present = $true
        }
        Else
        {
            $this.Present = $false
        }

        return $this
    }

    [bool] Test()
    {
        $this.OpenSession()

        $vm = Get-VM -Name $this.Name -ErrorAction SilentlyContinue

        $this.CloseSession()

        If (($vm) -and $this.Ensure -eq [Ensure]::Present)
        {
            return $true
        }
        ElseIf (-not($vm) -and $this.Ensure -eq [Ensure]::Absent)
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
                $task = New-VM -Name $this.Name -Template $this.Template -ResourcePool $this.ResourcePool -Location $this.Location
                Wait-Task -Task $task
            }
            Else
            {
                $task = New-VM -Name $this.Name -ResourcePool $this.ResourcePool -Location $this.Location
                Wait-Task -Task $task
            }
        }
        ElseIf ($this.Ensure -eq [Ensure]::Absent)
        {
            $task = Remove-VM -VM $this.Name -DeletePermanently
            Wait-Task -Task $task
        }

        $this.CloseSession()
    }
    
    [void] OpenSession()
    {
        Connect-VIServer -Server $this.vCenter -Credential $this.vCenterCredential -Force
    }

    [void] CloseSession()
    {
        Disconnect-VIServer -Server $this.vCenter -Force
    }
}


[DscResource()]
class StartVM
{
    [DscProperty(Key)]
    [string]$Name

    [DscProperty(Mandatory)]
    [string]$vCenter

    [DscProperty(Mandatory)]
    [PSCredential]$vCenterCredential

    [DscProperty(NotConfigurable)]
    [string]$State

    [StartVM] Get()
    {       
        $this.OpenSession()
        
        $this.State = Get-VM -Name $this.Name | Select-Object -ExpandProperty PowerState

        $this.CloseSession()

        return $this
    }

    [bool] Test()
    {
        $this.OpenSession()

        $status = Get-VM -Name $this.Name | Select-Object -ExpandProperty PowerState

        $this.CloseSession()

        If ($status -eq 'PoweredOff')
        {
            return $False
        }
        Else
        {
            return $true
        }
    }

    [void] Set()
    {
        $this.OpenSession()

        $task = Start-VM -VM $this.Name
        Wait-Task -Task $task

        $this.CloseSession()
    }
    
    [void] OpenSession()
    {
        Connect-VIServer -Server $this.vCenter -Credential $this.vCenterCredential -Force
    }

    [void] CloseSession()
    {
        Disconnect-VIServer -Server $this.vCenter -Force
    }
}