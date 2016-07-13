 

 

Table of Contents

PowerCLI Usefull Scripts And Commands
Getting all Possible Values for Objects
Commands And OneLiners
VM with CPU Reservation
Get All VMs and IP Addresses
VM with CPU Limit
VM with Memory Reservation
VM with Memory Limit
Get All CPU and Memory Values
VMWare Tools Version
Get Hosts with Specific Version
Get Datastores and Used Storage for VMs within Cluster
Get All Datastores for All Clusters and See Usage
Get Number of Paths in Use per Host within Cluster
Scan Storage for all Hosts within Cluster
Set MPIO Settings for All Hosts in Cluster
Count the Number of VMs in a Cluster That Match a Name Pattern
Get all Dead Paths In a Datacenter
Get All LUN IDs in use on an ESX Server
Get All LUN IDs in use on a NetApp Filer
Get All Volumes From NetApp Filer
Working with Credentials
Get the Number of VMs on all Datastores in a Datacenter
Get All VMs with Old Hardware Level Version
Set VM Description with CSV File
Scripts
Resource Pools with Ballooning and Swapping
VMs with Ballooning and Swapping
VMs Network Info
VMs Boot Time
Reading Values for Properties from CSV file
Combining PowerCLI and Powershell
Resources
Discussion
PowerCLI Usefull Scripts And Commands

This is an overview page with small PowerCLI scripts and or commands.

Getting all Possible Values for Objects

If only I knew then what I know now! When working on Script: PowerCLI: Create CSV with VMInfo I spent some serious time on finding what properties and values are available on certain objects. Today I finally figured it out, simply use “Select *”:

[vSphere PowerCLI] C:\> Get-NetworkAdapter -vm testvm01 | select *
 
 
MacAddress       : 00:50:56:89:2e:18
WakeOnLanEnabled : True
NetworkName      : SFT0-VLAN2
Type             : Flexible
ParentId         : VirtualMachine-vm-117451
Parent           : testvm01
Uid              : /VIServer=@localhost:443/VirtualMachine=VirtualMachine-vm-11
                   7451/NetworkAdapter=4000/
ConnectionState  : Connected:True
ExtensionData    : VMware.Vim.VirtualPCNet32
Id               : VirtualMachine-vm-117451/4000
Name             : Network adapter 1
Commands And OneLiners

 
VM with CPU Reservation

Get-VM | Get-VMResourceConfiguration | where {$_.CPUReservationMhz -ne '0'}
And setting the CPU reservation to 0:

Get-VM | Get-VMResourceConfiguration | where {$_.CPUReservationMhz -ne '0'} | Set-VMResourceConfiguration -CPUReservationMhz 0
Get All VMs and IP Addresses

Get-VM | Select Name, @{N="IP Address";E={@($_.guest.IPAddress[0])}}
Export to CSV:

Get-VM | Select Name, @{N="IP Address";E={@($_.guest.IPAddress[0])}} | Export-Csv c:\serverandip.csv
VM with CPU Limit

Get-VM | Get-VMResourceConfiguration | where {$_.CPULimitMhz -ne '-1'}
And setting the CPU limit to unlimited:

Get-VM | Get-VMResourceConfiguration | where {$_.CPULimitMhz -ne '-1'} | Set-VMResourceConfiguration -CPULimitMhz $null
VM with Memory Reservation

Get-VM | Get-VMResourceConfiguration | where {$_.MemReservationMB -ne '0'}
And setting the memory reservation to 0:

Get-VM | Get-VMResourceConfiguration | where {$_.MemReservationMB -ne '0'} | Set-VMResourceConfiguration -MemReservationMB 0
Note that if you change the memory reservation, and there is not enough free space in the datastore the next time the VM is powered on the operation will fail. To prevent this you can see all this information with this command:

ForEach ($vm in (Get-VM | Get-VMResourceConfiguration | where {$_.MemReservationMB -ne '0'} | ForEach {$_.VM})){Get-VM $vm | Select Name,PowerState,@{N="Reservation";E={Get-VMResourceConfiguration -VM $_ | ForEach {$_.MemReservationMB}}},@{N="Datastore";E={Get-Datastore -VM $_}},@{N="Datastore Free Space";E={Get-Datastore -VM $_ | ForEach {$_.FreeSpaceMB}}}}
This is a small script to automatically remove the reservation if the datastore has enough free space:

ForEach ($vm in (Get-VM | Get-VMResourceConfiguration | where {$_.MemReservationMB -ne '0'} | ForEach {$_.VM})){
  # $name = (Get-VM $vm | ForEach {$_.Name})
  $powerstate = (Get-VM $vm | ForEach {$_.PowerState})
  [int]$reservation = (Get-VMResourceConfiguration -VM $vm | ForEach {$_.MemReservationMB})
  $datastore = (Get-Datastore -VM $vm )
  [int]$dsfreespace = $datastore.FreeSpaceMB
  [int]$numberofds = (Get-Datastore -VM $vm |Measure-object).Count
  write-host "VM = $vm `n`t PowerState = $powerstate `n`t Memory Reservation = $reservation `n`t DataStore VM = $datastore `n`t Free Space on datastore = $dsfreespace `n`t Number of Datastores is $numberofds"
  if ((($dsfreespace - $reservation) -gt "0") -and ($numberofds -eq "1")){
     Write-Host "Now removing the memory reservation $reservation for VM $vm" -ForegroundColor Green
     Get-VMResourceConfiguration -VM $vm | Set-VMResourceConfiguration -MemReservationMB 0
  }
  else {
     Write-Host "Memory reservation ($reservation) cannot be removed because there is not enough free space on the datastore, or because the VM has multiple datastores." -ForegroundColor Red
  }
}
Note: if you just want to view the VMs for which the change cannot be done automatically comment the other Write-Host lines out.
VM with Memory Limit

Get-VM | Get-VMResourceConfiguration | where {$_.MemLimitMB -ne '-1'}
And setting the memory limit to unlimited:

Get-VM | Get-VMResourceConfiguration | where {$_.MemLimitMB -ne '-1'} | Set-VMResourceConfiguration -MemLimitMB $null
Get All CPU and Memory Values

$startdir = "D:\sjoerd"
$csvfile = "$startdir\memlimits.csv"
 
$myCol = @()
 
foreach ($VM in (Get-VM | Get-VMResourceConfiguration | where {$_.MemLimitMB -ne '-1'})){
 
$vmview = Get-VM $VM | Get-View
 
$VMInfo = "" |select-Object VMName,CPUReservation,CPULimit,CPUShares,NumCPU,MEMSize,MEMReservation,MEMLimit,MEMShares
$VMInfo.VMName = $vmview.Name
$VMInfo.CPUReservation = $vmview.Config.CpuAllocation.Reservation
If ($vmview.Config.CpuAllocation.Limit-eq "-1"){$VMInfo.CPULimit = "Unlimited"}
Else{$VMInfo.CPULimit = $vmview.Config.CpuAllocation.Limit}
$VMInfo.CPUShares = $vmview.Config.CpuAllocation.Shares.Shares
$VMInfo.NumCPU = $VM.NumCPU
$VMInfo.MEMSize = $vmview.Config.Hardware.MemoryMB
$VMInfo.MEMReservation = $vmview.Config.MemoryAllocation.Reservation
If ($vmview.Config.MemoryAllocation.Limit-eq "-1"){$VMInfo.MEMLimit = "Unlimited"}
Else{$VMInfo.MEMLimit = $vmview.Config.MemoryAllocation.Limit}
 
$myCol += $VMInfo
}
 
$myCol |Export-csv -NoTypeInformation $csvfile
VMWare Tools Version

get-vm |% { get-view $_.id } | select Name, @{ Name=";ToolsVersion";; Expression={$_.config.tools.toolsVersion}}
Get Hosts with Specific Version

get-vmhost | where-object { $_.version -eq "4.1.0" } | select name,version
Get Datastores and Used Storage for VMs within Cluster

Get-Cluster "Acceptance" | Get-VM | Select Name, @{N="Datastore";E={Get-Datastore -vm $_}}, UsedSpaceGB, ProvisionedSpaceGB  | sort Name | Export-Csv F:\Scripts\Output\datastores-acceptance.csv
Get All Datastores for All Clusters and See Usage

ForEach ($cluster in get-cluster){get-cluster "$cluster" | Get-VMHost | select -first 1 | get-datastore | where {$_.name -like "?_*"&#125#125; | Select Name,FreeSpaceMB,CapacityMB,@{N="Number of VMs";E={@($_ | Get-VM).Count}},@{N="VMs";E={@($_ | Get-VM | ForEach-Object {$_.Name})}},@{N="VM Size";E={@($_ | Get-VM | ForEach-Object {$_.UsedSpaceGB})}} | Export-Csv D:\sjoerd\datastore-$cluster-overview.csv}
Get Number of Paths in Use per Host within Cluster

Get-Cluster "Acceptance" | Get-VMHost | where {$_.State -eq "Connected"} | Select Name, @{N="TotalPaths";E={($_ | Get-ScsiLun | Get-ScsiLunPath | Measure-Object).Count}}
Scan Storage for all Hosts within Cluster

ForEach ($esxhost in (Get-Cluster "Acceptance" | Get-VMHost)) {Get-VmHostStorage $esxhost -RescanAllHba}
Set MPIO Settings for All Hosts in Cluster

ForEach ($esxhost in (Get-Cluster "Acceptance" | Get-VMHost)) {D:\tools\plink -ssh $esxhost -l root -pw <fillinpw> /opt/ontap/santools/config_mpath --primary --loadbalance --policy fixed}
Count the Number of VMs in a Cluster That Match a Name Pattern

get-cluster "acceptance" | get-vm | where {$_.name -match "prd"} | measure-object
Get all Dead Paths In a Datacenter

ForEach ($vmhost in (Get-Datacenter "The Netherlands" | Get-Vmhost | Sort)){ $deadpaths = Get-ScsiLun -vmhost $vmhost | Get-ScsiLunPath | where {$_.State -eq "Dead"} | Select ScsiLun,State; Write-Host $vmhost $deadpaths}
Get All LUN IDs in use on an ESX Server

Get-ScsiLun -vmhost esx01 -luntype disk | select runtimename | sort runtimename
Get All LUN IDs in use on a NetApp Filer

Get-NaLun | get-nalunmap | select Path,LunId | Sort LunId
Get All Volumes From NetApp Filer

This will get you all Volumes from a NetApp Filer that start with a capital R and an underscore, separated by a comma, and copied to the clipboard. I needed this to get all volumes that are part of replication:

import-module D:\sjoerd\dataontap
connect-nacontroller filer01 -credential (Get-credential)
(Get-NaVol | where {$_.name -like "R_*"} | select name -expandproperty Name) -join ',' | clip
Working with Credentials

If you need to submit credentials for connecting to something you can do this to get a prompt for entering the credentials in stead of having to put them on the commandline:

Connect-NaController filer01 -Credential (Get-Credential)
Get the Number of VMs on all Datastores in a Datacenter

Get-Datastore | where {$_.datacenter -match "The Netherlands"} | Select Name, @{N="Number of VMs";E={@($_ | Get-VM).Count}} | Sort "Number of VMs"
Get All VMs with Old Hardware Level Version

Get-Cluster "Acceptance" | Get-VM | Get-View | Where {$_.Config.Version -ne "vmx-09"} | Select Name | Sort Name
Set VM Description with CSV File

Note: This command will overwrite the existing descriptions, so make sure you do not overwrite anything important.
You need to create a simple csv file which looks like this:

VMName,Description
server01,Domain Controller
server02,Database Server
The second step is to run this command:

Import-Csv "D:\sjoerd\description.csv" | % { Set-VM $_.VMName -Description $_.Description -Confirm:$false}
That's all!

Scripts

Save the code on your management workstation in a simple textfile, and change the extention to “.ps1”. Now you can run them from powershell like any executable.

Resource Pools with Ballooning and Swapping

$myCol = @()
foreach($clus in (Get-Cluster)){
 foreach($rp in (Get-ResourcePool -Location $clus | Get-View | Where-Object `
  {$_.Name -ne "Resources" -and `
   $_.Summary.QuickStats.BalloonedMemory -ne "0"})){
   $Details = "" | Select-Object Cluster, ResourcePool, `
   SwappedMemory ,BalloonedMemory
 
    $Details.Cluster = $clus.Name
    $Details.ResourcePool = $rp.Name
    $Details.SwappedMemory = $rp.Summary.QuickStats.SwappedMemory
    $Details.BalloonedMemory = $rp.Summary.QuickStats.BalloonedMemory
 
    $myCol += $Details
  }
}
$myCol
VMs with Ballooning and Swapping

$myCol = @()
foreach($vm in (Get-View -ViewType VirtualMachine | Where-Object `
  {$_.Summary.QuickStats.BalloonedMemory -ne "0"})){
   $Details = "" | Select-Object VM, `
   SwappedMemory ,BalloonedMemory
 
    $Details.VM = $vm.Name
    $Details.SwappedMemory = $vm.Summary.QuickStats.SwappedMemory
    $Details.BalloonedMemory = $vm.Summary.QuickStats.BalloonedMemory
 
    $myCol += $Details
  }
$myCol
VMs Network Info

(get-vm) | %{
  $vm = $_
  echo $vm.name----
  $vm.Guest.Nics | %{
    $vminfo = $_
    echo $vminfo.NetworkName $vminfo.IPAddress $vminfo.MacAddress
    echo ";`n";
  }
}
VMs Boot Time

$LastBootProp = @{
  Name = 'LastBootTime'
    Expression = {
      ( Get-Date ) - ( New-TimeSpan -Seconds $_.Summary.QuickStats.UptimeSeconds )
	}
}
 
Get-View -ViewType VirtualMachine -Property Name, Summary.QuickStats.UptimeSeconds | Select Name, $LastBootProp
Reading Values for Properties from CSV file

This little snippet will set the memory reservations for a VM from a csv file. This is useful if you want to rollback a change and you remembered to make a csv file with VM information. You can use the list to make a separate vms.txt file as input as well as a vmsinput.txt file with reservation settings: 
vms.txt:

WINXP-TESTVM2
WINXP-TESTVM3
WINXP-TESTVM4
vmsinput.txt:

VMName,MEMReservation
WINXP-TESTVM2,128
WINXP-TESTVM3,256
WINXP-TESTVM4,128
$sourcevms = "C:\Users\sjoerd\Desktop\powercli scripts\vms.txt"
$sourcememory = "C:\Users\sjoerd\Desktop\powercli scripts\vmsinput.txt"
 
$list = Get-Content $sourcevms | Foreach-Object {Get-VM $_ } 
 
foreach($item in $list){
                $vm = $item.Name
		# The line below gives all information in @= format. This is not directly usable. 				
		$memres = import-csv $sourcememory | where-object {$_.vmname -eq "$vm"} 
		# With this you get only the value of the property in the variable.
		$memresvm = $memres.MEMReservation
		Get-VM $vm | Get-VMResourceConfiguration | where {$_.MemReservationMB -eq '0'} | Set-VMResourceConfiguration -MemReservationMB $memresvm
		}
 
Combining PowerCLI and Powershell

This snippet queries the windows host machine for the uptime.

$vms = get-vm | where { ($_.PowerState -eq "PoweredOn") } | get-view | where { ($_.Guest.GuestFamily -eq "windowsGuest") } 
 
foreach ($vm in $vms) {
   $vmname = $vm.name
   $hostname = $vm.Guest.HostName
   write-host "Starting with $vmname with hostname $hostname"
   Get-WmiObject -computer $hostname
   $objUptime = (Get-WmiObject -computer $hostname -class Win32_PerfFormattedData_PerfOS_System).SystemUpTime
   write-host "$vmname heeft $objUptime as uptime"
}
 
