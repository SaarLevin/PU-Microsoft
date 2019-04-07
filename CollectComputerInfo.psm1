function Collect-Computer-Info {
        [CmdletBinding()]
        param(
            [Parameter(
                #Mandatory=$True,
                Position=1,
                ValueFromPipeline=$True,
                ValueFromPipelineByPropertyName=$True)]
                [String[]]$ComputerName='localhost',

                [Switch]$OSInfo,
                [Switch]$SoftwareInfo,
                [Switch]$HWInfo,
                [Switch]$HotFix,
                [Switch]$DiskSpaceInfo
        )

        if ($OSInfo) {
            $operatingSystem = Get-CimInstance Win32_OperatingSystem -ComputerName $ComputerName
            $osObject = [PSCustomObject] @{ 
                OS             = $operatingSystem.Caption
                Version        = $operatingSystem.Version
                SerialNumber   = $operatingSystem.SerialNumber
                InstallDate    = ($operatingSystem.InstallDate).ToString("yyyy-MM-dd")
                LastRebootTime = ($operatingSystem.LastBootUpTime).ToString("yyyy-MM-dd HH:mm")   
            }
            #Write-Host ""
            Write-Host "################################################################################################" -BackgroundColor Green -ForegroundColor Black
            Write-Host "                                       Operating System Info                                    " -BackgroundColor Green -ForegroundColor Black
            Write-Host "################################################################################################" -BackgroundColor Green -ForegroundColor Black
            #Write-Host ""
            $osObject            
        }
        
        if ($SoftwareInfo) {
            $software = Get-CimInstance Win32_Product -ComputerName $ComputerName
            $softObject = @()
            $software | ForEach-Object { 
                $softObject += [PSCustomObject] @{
                    Name    = $_.Name
                    Vendor  = $_.Vendor
                    Version = $_.Version

                }
            }
            #Write-Host ""
            Write-Host "################################################################################################" -BackgroundColor Yellow -ForegroundColor Black
            Write-Host "                                      Installed Software Info                                   " -BackgroundColor Yellow -ForegroundColor Black
            Write-Host "################################################################################################" -BackgroundColor Yellow -ForegroundColor Black
            #Write-Host ""
            $softObject | ft -AutoSize   
        }
        
        if ($HWInfo) {
            $desktop        = Get-CimInstance -ClassName Win32_BIOS -ComputerName $ComputerName
            $computerSystem = Get-CimInstance -ClassName Win32_ComputerSystem -ComputerName $ComputerName
            $process        = Get-CimInstance -ClassName Win32_Processor -ComputerName $ComputerName
            $hwObject = [PSCustomObject] @{
                Manufacturer  = $desktop.Manufacturer
                System        = $computerSystem.SystemFamily
                SerialNumber  = $desktop.SerialNumber
                Model         = $computerSystem.Model
                Process       = $process.Name
                TotalMemoryGB = [int]($computerSystem.TotalPhysicalMemory/1gb)
            }
            #Write-Host ""
            Write-Host "################################################################################################" -BackgroundColor Cyan -ForegroundColor Black
            Write-Host "                                           Hardware Info                                        " -BackgroundColor Cyan -ForegroundColor Black
            Write-Host "################################################################################################" -BackgroundColor Cyan -ForegroundColor Black
            #Write-Host ""
            $hwObject
        
        }
        
        if ($hotFix) {
            $updates = Get-HotFix -ComputerName $ComputerName | select @{n="HotFixNumber";e={$_.HotFixID}},@{n="Type";e={$_.Description}},InstalledOn 
            #Write-Host ""
            Write-Host "################################################################################################" -BackgroundColor Cyan -ForegroundColor Black
            Write-Host "                                           HotFix Info                                          " -BackgroundColor Cyan -ForegroundColor Black
            Write-Host "################################################################################################" -BackgroundColor Cyan -ForegroundColor Black
            $updates
        }
        
        if ($diskSpaceInfo) {
            $diskSpace = Get-WmiObject Win32_LogicalDisk -ComputerName $ComputerName -Filter "DriveType='3'" | Select `
                DeviceID,VolumeName,@{n="TotalSize(GB)";e={"{0:N1}" -f ($_.size /1GB)}},@{n="FreeSpace(GB)";e={"{0:N1}" -f ($_.FreeSpace/1GB)}},
                    @{n="FreePercentage";e={"{0:P0}" -f ($_.FreeSpace/$_.size)}}     

            #Write-Host ""
            Write-Host "################################################################################################" -BackgroundColor Red
            Write-Host "                                         HD Space Info                                          " -BackgroundColor Red
            Write-Host "################################################################################################" -BackgroundColor Red
            $diskSpace
        }    
}