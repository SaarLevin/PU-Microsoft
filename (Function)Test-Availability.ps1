<#
    .NOTES
    ===========================================================================
     Created on:    28.4.2019
     Created by:    Saar Levin
     Organization:
    ===========================================================================
#>

function Test-Availability {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True)]
        [string]$ComputerName
    )
    Begin {
        $colStatus = @()
    }
    Process {
        $obj = [PSCustomObject]@{
            Computer = $ComputerName
            Status    = "UP"
        }
        $check = Test-Connection -ComputerName $ComputerName -Quiet -Count 3
        if (!($check)) { $obj | Add-Member -Name Status -Value "Down" -Force }
        $colStatus += $obj
    }
    End { $colStatus }
}