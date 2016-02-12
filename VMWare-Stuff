 
Starting a virtual machine via the command line of an ESX/ESXi host
To start a virtual machine from the service console of an ESX/ESXi host:

Log into the VMware ESX/ESXi host as the root user.
 
To list all running virtual machines and their corresponding VMIDs, run the command:
 
::
 
 vim-cmd vmsvc/getallvms

::

 vim-cmd vmsvc/getallvms | sed '1d' | awk '{if ($1 > 0) print $1":"$2}'


Power on the virtual machine using the VMID found in Step 2 and run:

::
 
 vim-cmd vmsvc/power.on <vmid> 

 vim-cmd vmsvc/power.off <vmid> 

::
 
 esxcli vm process list


 
