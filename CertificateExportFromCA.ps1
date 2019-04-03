<#     
    .NOTES 
    =========================================================================== 
     Created on:	  3.4.2019     
     Created by:      Saar Levin
     Organization:      
    =========================================================================== 
    .DESCRIPTION 
        This script will collect the certificate and filter the expired CA
#> 

#region Main Variables
$csvCert    = "C:\temp\cert.csv"            ## NEED TO CHANGE
$warningExp = (get-date).AddDays(360)       ## NEED TO CHANGE
$today      = Get-Date
#endregion

#region Export CSV from CA
certutil.exe -view -csv > $csvCert
#endregion

#region Collect Expiration Date
$importCsv = Import-Csv $csvCert
$filterRows = $importCsv | Select @{n="RequestID";e={$_.'Request ID'}} , @{n="CertificateTemplate";e={$_.'Certificate Template'}} , `
    @{n="CertificateEffectiveDate";e={[datetime]$_.'Certificate Effective Date'}} , @{n="CertificateExpirationDate";e={[datetime]$_.'Certificate Expiration Date'}}, `
        @{n="RequesterName";e={$_.'Requester Name'}}

$needToRenew = $filterRows | ? { ($_.CertificateExpirationDate -le $warningExp) -and ($_.CertificateExpirationDate -ge $today) }

$needToRenew
#endregion