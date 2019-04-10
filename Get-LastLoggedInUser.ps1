
function Get-LastLoggedInUser {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String]$ComputerName="LocalHost"
    )

    Begin {}
    Process {
        $LastLogOn = (Get-WmiObject -Class win32_process -ComputerName $ComputerName | Where-Object name -Match explorer).getowner().user    
    }
    End {
        return $LastLogOn
    }   
}