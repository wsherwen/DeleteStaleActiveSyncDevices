$Logfile = "$env:windir\Temp\Logs\RemoveStaleActiveSync.log"
Function LogWrite{
   Param ([string]$logstring)
   Add-content $Logfile -value $logstring
   write-output $logstring
   
}
function Get-TimeStamp {
    return "[{0:dd/MM/yy} {0:HH:mm:ss}]" -f (Get-Date)
}

if (!(Test-Path "$env:windir\Temp\Logs\"))
{
   mkdir $env:windir\Temp\Logs
   LogWrite "$(Get-TimeStamp): Script has started."
   LogWrite "$(Get-TimeStamp): Log directory created."
}
else
{
    LogWrite "$(Get-TimeStamp): Script has started."
    LogWrite "$(Get-TimeStamp): Log directory exists."
}

LogWrite "$(Get-TimeStamp): Setting Cut Off Date."
$cutoff = (Get-Date).AddDays(-30)
LogWrite "$(Get-TimeStamp): Finding devices that havn't sync'd for 30 days."
$devices = Get-MobileDevice | Where-Object { $_.LastSuccessSync -lt $cutoff }
LogWrite "$(Get-TimeStamp): Creating report of devices."
$devices | Export-Csv $env:windir\Temp\Logs\DeletedActiveSyncDevices.csv

foreach ($device in $devices) {
    Remove-MobileDevice -Identity $device.Identity -Confirm:$false 
    LogWrite "$(Get-TimeStamp): Removed device $device."
}

LogWrite "$(Get-TimeStamp): The script has been executed, now exiting..."
exit