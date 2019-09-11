### FreeSpaceOnDisksOnServers ###
## Should check all servers in a given txt file by name (Hostname or FQDN) and report is server is online and how much free space and capacity is on connected disks
## 
##
## Get the path for the file with content server names for targets
## This file has to be in the same folder as the script
$path=Split-Path $MyInvocation.MyCommand.path
#
## For no red error messages in code uncomment following line
#$ErrorActionPreference= 'silentlycontinue'
#
##Get credentials, if script is not executed as domain admin
##Remove # before next line and in front of parameter in line 32
#$cred= get-credential
#
##Get Server Names out of file whemn there is no # before its name
$servers = get-content "$path\servers.txt" | Where-Object {!($_ -match "#")}
$array = @()
$ping = New-Object System.Net.NetworkInformation.Ping
#Looping each server servers.txt
foreach ($server in $servers) 
{ 
$serverIP = $null
$object = $null
$value = $null
# Ping server
$serverIP = ($ping.Send($server).Address)
#If a Ip for the server name was found, it is given out as string, else a not found
If($serverIP)
    {
        $value = $serverIP.IPAddressToString
        $disks = $null
        $disks = Get-wmiobject -computername $server -Query "Select DeviceID,Size,FreeSpace From Win32_LogicalDisk Where DriveType='3'" #-Credential $cred
        if($disks)
            {
              foreach($objDisk in $disks){
                $freeSpace = [math]::round($objDisk.FreeSpace / 1GB, 2).tostring("0.00")+" GB"
                $size = [math]::round($objDisk.Size / 1GB, 2).tostring("0.00")+" GB"
                $copyPaste = $freeSpace + "/" + $size
                $temp = $objDisk.FreeSpace/$objDisk.Size
                $freePercentage = $temp.tostring("P")
                $object = New-Object PSObject -Property ([ordered]@{ 
                    Server                  = $server
                    IPAddress               = $value
                    Drive                   = $objDisk.DeviceID
                    Freespace               = $freeSpace
                    Size                    = $size
                    CopyPate                = $copyPaste
                    FreeSpaceInPercent      = $freePercentage
                     })
                # Add object to array
                $array += $object
                #Display object
                $object
                }
            }
            Else
            {
            $object = New-Object PSObject -Property ([ordered]@{ 
                Server                  = $server
                IPAddress               = $value
                Drive                   = 'NA'
                Freespace               = 'NA'
                Size                    = 'NA'
                })
            $array += $object        
            $object
        }
    }
    Else 
    {
         #When Server is not rechable via ping
         $value = "(not found)"
         $object = New-Object PSObject -Property ([ordered]@{ 
                Server                  = $server
                IPAddress               = $value
                Drive                   = 'NA'
                Freespace               = 'NA'
                Size                    = 'NA'
                })
        $array += $object        
        $object
    }
 
}
If($array)
{
    #Save CSV file with results in same folder with timestamp in name
    $array | Export-Csv -Path "$path\$(get-date -f yyyy-MM-dd--HH-mm)ServerDiskSpace.csv" -NoTypeInformation
}
