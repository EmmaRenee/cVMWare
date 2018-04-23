@{
    AllNodes = 
    @(
        @{     
            NodeName = "*"
            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser = $true
        },

        @{
            NodeName = 'NameOfAuthoringMachine'
            Task = 'NewVMs'
        }
    )

    NonNodeData =
    @{
        Tasks = 
        @{
            'NewVMs' = 
            @(
                @{
                    VMName     = 'VM1'
                    vCenter    = 'vCenter.home.lab'
                    VMTemplate = 'Windows Server 2016 Standard'
                    Cluster    = 'Cluster Name'
                    Location   = 'DSC Demo'
                },

                @{
                    VMName     = 'VM2'
                    vCenter    = 'vCenter.home.lab'
                    VMTemplate = 'Windows Server 2016 Standard'
                    Cluster    = 'Cluster Name'
                    Location   = 'DSC Demo'
                }  
            )
        }
    }
}