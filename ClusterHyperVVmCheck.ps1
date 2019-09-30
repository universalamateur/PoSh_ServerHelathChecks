# Documentation and live used ram
$array = @()
$arrayHosts = @()
$Cluster = Get-Cluster
$Hostnames=(Get-Cluster $Cluster | Get-ClusterNode).Name
$i=0
$path=Split-Path $MyInvocation.MyCommand.path
$line='---'
$overcomitted=''
$dataHost = $null
$dataHost = New-Object PSObject -Property ([ordered]@{
        name = "Host"
        host = "Ttl Startupmem Dynamic VMs"
        State = "in GB"
	    Status = "Ttl Staticmem Static VMs"
        Uptime= "in GB"
        Heartbeat = "Ttl minimum RAM (Startup+Static)"
        CPU = "required in GB"
        memoryStartup = "Ttl Maxmem Dynamic VMs"
        memoryMaximum = "in GB"
        dynamicMemoryEnabled = "Ttl available"
        memoryAssigned = "memory in GB"
        memoryDemand = "-"
})
$arrayHosts += $dataHost

foreach ($Host1 in $Hostnames) {
    [int]$hostmem=@{} | Out-Null
    [int]$totalstartupmem=@{} | Out-Null
    [int]$totalmaxmem=@{} | Out-Null
    [int]$staticmemory=@{} | Out-Null
    [int]$overcommited=@{} | Out-Null
    [int]$totalramrequired=@{} | Out-Null

    $AllVMs=(get-vm -ComputerName $Host1).Name
    $Hostmem=(Get-VMhost -ComputerName $Host1).MemoryCapacity / 1024 / 1024 / 1024

    foreach ($VM in $AllVMs) {
        $CurrentVM=(get-VM $VM -ComputerName "$Host1" | fl *)
        if ((Get-VMMemory -vmname $VM -ComputerName "$Host1").DynamicMemoryEnabled -eq "True") {
            $memorystartup=(get-vm $VM -ComputerName "$Host1" | select-object MemoryStartup).MemoryStartup /1024 / 1024 / 1024
            $MemoryMaximum=(get-vm $VM -ComputerName "$Host1" | select-object MemoryMaximum).memorymaximum /1024 / 1024 / 1024
            $MemoryAssigned=[math]::round((get-vm $VM -ComputerName "$Host1" | select-object MemoryAssigned).memoryassigned /1024 / 1024 / 1024, 2)
            $MemoryDemand=[math]::round((get-vm $VM -ComputerName "$Host1" | select-object MemoryDemand).memorydemand /1024 / 1024 / 1024, 2)
            $MemoryStatus=(get-vm $VM -ComputerName "$Host1" | select-object MemoryStatus).memorystatus
            $totalstartupmem += $memorystartup
            $totalmaxmem += $MemoryMaximum
        }
        else {
            $static=(get-vm $VM -ComputerName "$Host1" | select-object MemoryStartup).MemoryStartup /1024 / 1024 / 1024
            $staticmemory += $static
            $stringMemorystartup=$static
            $MemoryMaximum=$static
            $MemoryAssigned=$static
            $MemoryDemand=0
            $MemoryStatus="StAtIc"
        }
        $dataVM = $null
        $stringMemorystartup=[string]$memorystartup + ' GB'
        $StringMemoryMaximum=[string]$MemoryMaximum + ' GB'
        $tringMemoryAssigned=[string]$MemoryAssigned + ' GB'
        $tringMemoryDemand=[string]$MemoryDemand + ' GB'
        $StringMemoryStatus=[string]$MemoryStatus
        $dataVM = New-Object PSObject -Property ([ordered]@{
            name = $VM
            host = $Host1
            State = (Get-vm $VM -ComputerName "$Host1").State
            Status = (Get-vm $VM -ComputerName "$Host1").Status
            Uptime = (Get-vm $VM -ComputerName "$Host1").Uptime
            Heartbeat = (Get-vm $VM -ComputerName "$Host1").Heartbeat
            CPU = (get-vm $VM -ComputerName "$Host1").ProcessorCount
            memoryStartup = $stringMemorystartup
            memoryMaximum = $StringMemoryMaximum
            dynamicMemoryEnabled = (Get-VMMemory -vmname $VM -ComputerName "$Host1").DynamicMemoryEnabled
            memoryAssigned = $tringMemoryAssigned
            memoryDemand = $tringMemoryDemand
            memoryStatus = $StringMemoryStatus
            IntegrationServicesState = (Get-vm $VM -ComputerName "$Host1").IntegrationServicesState
            IntegrationServicesVersion = (Get-vm $VM -ComputerName "$Host1").IntegrationServicesVersion
            ReplicationStat = (get-vm $VM -ComputerName "$Host1").ReplicationState
            ReplicationHeal = (get-vm $VM -ComputerName "$Host1").ReplicationHealth
            ReplicationMode = (get-vm $VM -ComputerName "$Host1").ReplicationMode
            VMId = (get-vm $VM -ComputerName "$Host1").VMId
            Path = (Get-vm $VM -ComputerName "$Host1").Path
            ConfigurationLocation = (Get-vm $VM -ComputerName "$Host1").ConfigurationLocation
            SnapshotFileLocation = (Get-vm $VM -ComputerName "$Host1").SnapshotFileLocation
            SmartPagingFilePath = (Get-vm $VM -ComputerName "$Host1").SmartPagingFilePath
            ParentSnapshotId = (Get-vm $VM -ComputerName "$Host1").ParentSnapshotId
            ParentSnapshotName = (Get-vm $VM -ComputerName "$Host1").ParentSnapshotName
            AutomaticStopAction = (Get-vm $VM -ComputerName "$Host1").AutomaticStopAction
            AutomaticStartAction = (Get-vm $VM -ComputerName "$Host1").AutomaticStartAction
            AutomaticStartDelay = (Get-vm $VM -ComputerName "$Host1").AutomaticStartDelay
        })

        $array += $dataVM
    }
    $totalramrequired=$totalstartupmem + $staticmemory
    write-host "Sum Rep for $Host1" -foregroundcolor green
    write-host "Ttl Startupmem for Dynamic VMs $totalstartupmem GB " -foregroundcolor green
    write-host "Ttl Staticmem for Static VMs $staticmemory GB " -foregroundcolor green
    write-host "Ttl minimum RAM (Startup+Static) required $totalramrequired GB " -foregroundcolor yellow
    write-host "Ttl Maxmem for Dynamic VMs $totalmaxmem GB " -foregroundcolor yellow
    write-host "Ttl available memory $Hostmem GB " -foregroundcolor green
    if ($totalmaxmem -gt $Hostmem) {
        Write-Host "$Host1 is overcomitted " -foregroundcolor red
        $overcomitted="$Host1 is overcomitted "
    }
    write-host " "
    $dataVM = $null
    $dataVM = New-Object PSObject -Property ([ordered]@{
        name = $line
        host = $line
        State = $line
	    Status = $line
    })
    $array += $dataVM
    $dataHost = $null
    $dataHost = New-Object PSObject -Property ([ordered]@{
        name = "Sum Rep for $Host1"
        host = "-"
        State = $totalstartupmem
	    Status = "-"
        Uptime= $staticmemory
        Heartbeat = "-"
        dynamicMemoryEnabled = $totalramrequired
        memoryAssigned = "-"
        memoryDemand = $totalmaxmem
        memoryStatus = "-"
        IntegrationServicesState = $Hostmem
        IntegrationServicesVersionIntegrationServicesVersion = $overcomitted
    })
    $arrayHosts += $dataHost
}
$date=get-date -f yyyy-MM-dd--HH-mm
If($array)
{
    #Save CSV file with results in same folder with timestamp in name
    $array | Export-Csv -Path "$path\$date ClusterState.csv" -NoTypeInformation
}
If($arrayHosts)
{
    #Save CSV file with results in same folder with timestamp in name
    $arrayHosts | Export-Csv -Path "$path\$date ClusterState.csv" -NoTypeInformation -Append -Force
}
