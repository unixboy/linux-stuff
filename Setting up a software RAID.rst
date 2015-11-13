Setting up a software RAID on Linux Debian based distros such as Ubuntu is surprisingly easy.  And these days, software RAID arrays are nearly as efficient as hardware raids without the drawback of having your data inaccessible if the hardware RAID controller goes haywire.  This tutorial outlines the basics for setting up a software RAID array using mdadm on an existing previously installed Ubuntu system.
Contents

    Hardware
    Preparing the Hard Drives
    Creating the RAID 1 Array Using mdadm
    Deleting the mdadm RAID Array

Hardware

Firstly you’ll need at least two hard drives, depending on what RAID level you want:


RAID Level 	Min # of Disks 	Benefits 	Details
0 	2 	Good Read & Write Performance 	

    Also called a stripe set or stripe volume.
    Increases performance for data intensive apps by alternating stripes of data on two different disks.  In other words, RAID 0 increases throughput by writing half of the data to two different disks simultaneously.

1 	2 	Good Redundancy 	

    Also called a mirror.
    Increases data security by writing the same data to both disks simultaneously.  In the case of a single hard drive failure, the second drive will still have all the data and the system will suffer no down time.  Once the failed drive is replaced, it will be synced with the existing disk’s data.

5 	3 	Good Read Performance &
Redundancy 	

    Increases performance via striping (distributing data across multiple drives) and increases redundancy via parity (the data for the same block location on two drives has a parity block – calculated by XORing the data blocks – on the third drive’s block location, which can then be used with either of the other two drive’s block’s data to reconstruct a missing drive’s block data).
    Read operations from disk are fast, thanks to data being pulled from all disks simultaneously.
    Write operations to disk are slow, due to overhead in calculating and writing parity data.

10 	4 	Excellent Read & Write Performance &
Redundancy 	

    Increases performance via striping (distributing data across multiple drives) and increases redundancy via mirroring (the same data is written to multiple drives).
    Read operations from disk are fast, thanks to data being pulled from multiple disks simultaneously.
    Write operations to disk are fast, thanks to data being written to multiple disks simultaneously.

For this tutorial we will use the simplest example for data redundancy: two 1.0 TB disks in a RAID 1 configuration.
Preparing the Hard Drives

If you have two drives of different sizes (eg, one disk is 1.5 TB and the other is 1.0 TB), ensure that the partitions on each are the same (eg, both disks have a 1.0 TB primary partition).  While mdadm can compensate for different sized partitions, there is no sense in wasting the extra space, as another partition can be created and used independently of the RAID array in the surplus space.

The easiest method to create the partitions if you have a window manager installed is to use GParted.  There’s no need to format the partitions, as that will be done as part of the RAID assembly process.  In this example, we are using sda and sdb:

GParted_RAID
Creating the RAID 1 Array Using mdadm

If you haven’t already, install mdadm:
?
$ sudo apt-get install mdadm

mdadm has an extremely simple and self-explanatory instruction set.  This tutorial will demonstrate most of the commands.

    Create a new RAID array using the two disks you’ve prepared.  mdadm will output some diagnostic data, then ask you if you’re sure you want to continue creating the array.
    ?
    $ sudo mdadm --create --verbose /dev/md0 --level=1 /dev/sda1 /dev/sdb1
    mdadm: Note: this array has metadata at the start and
        may not be suitable as a boot device.  If you plan to
        store '/boot' on this device please ensure that
        your boot-loader understands md/v1.x metadata, or use
        --metadata=0.90
    mdadm: size set to 976629568K
    Continue creating array? y
    mdadm: Defaulting to version 1.2 metadata
    mdadm: array /dev/md0 started.

    “––verbose” ensures that all mdadm information will be presented during the process.
    “––level=1” refers to the RAID level being created.
    “/dev/sda1 /dev/sdb1” can be shortened to “/dev/sd[ab]1“.
    Assemble the RAID disks together & add them to /etc/mdadm/mdadm.conf.  Your system uses this file to recognize and organize software RAID array devices on boot.
    Since in this tutorial this is the only RAID array on the system, it will be created as /dev/md0.  This can be done in several ways:

        Quick & easy, finds all RAID arrays and records them (may fubar existing RAID arrays):
        ?
        $ sudo mdadm --assemble --scan
        Specifically assembles the particular RAID array we are creating (recommended):
        ?
        $ sudo mdadm --assemble /dev/md0 /dev/sda1 /dev/sdb1
    Wait for the RAID array to finish assembling (this may take some time).  You can check the progress periodically using the command cat /proc/mdstat, or you can get a running progress report using watch cat /proc/mdstat.   (you can exit the watch by pressing CTRL-C)  Depending on the size and speed of your drives, this may take several hours.
    Check to make sure that everything looks good with the new RAID device.  There should be 2 active and working devices, sda1 and sdb1, and the state should be clean:
    ?
    $ sudo mdadm --detail /dev/md0
    /dev/md0:
            Version : 1.2
      Creation Time : Fri Jul  5 15:43:54 2013
         Raid Level : raid1
         Array Size : 976629568 (931.39 GiB 1000.07 GB)
      Used Dev Size : 976629568 (931.39 GiB 1000.07 GB)
       Raid Devices : 2
      Total Devices : 2
        Persistence : Superblock is persistent
     
        Update Time : Fri Jul  5 21:45:27 2013
              State : clean
     Active Devices : 2
    Working Devices : 2
     Failed Devices : 0
      Spare Devices : 0
     
               Name : msit01.mysolutions.it:0  (local to host msit01.mysolutions.it)
               UUID : cb692413:bc45bca8:4d49674b:31b88475
             Events : 17
     
        Number   Major   Minor   RaidDevice State
           0       8        1        0      active sync   /dev/sda1
           1       8       17        1      active sync   /dev/sdb1
    Format the new RAID device:
    ?
    $ sudo mke2fs /dev/md0
    mke2fs 1.42 (29-Nov-2011)
    Filesystem label=
    OS type: Linux
    Block size=4096 (log=2)
    Fragment size=4096 (log=2)
    Stride=0 blocks, Stripe width=0 blocks
    61046784 inodes, 244157392 blocks
    12207869 blocks (5.00%) reserved for the super user
    First data block=0
    Maximum filesystem blocks=0
    7452 block groups
    32768 blocks per group, 32768 fragments per group
    8192 inodes per group
    Superblock backups stored on blocks:
            32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208,
            4096000, 7962624, 11239424, 20480000, 23887872, 71663616, 78675968,
            102400000, 214990848
     
    Allocating group tables: done
    Writing inode tables: done
    Writing superblocks and filesystem accounting information: done
    Create a directory for the mount point where ever you like for your RAID device, and give the mount point whatever permissions your system requires for user access.  In this tutorial, user root & group test-user will own the mount point, with both the user and the group having read/write/execute permissions, and everyone else having read/execute permissions:
    ?
    1
    2
    3
    	
    $ sudo mkdir /media/RAID1_0
    $ sudo chown root:test-user
    $ sudo chmod 775 /media/RAID1_0
    Find the UUID for your RAID array device (for use in auto-mounting at boot via /etc/fstab):
    ?
    $ sudo blkid | grep md0
    /dev/md0: UUID="d409ca76-9eee-40ea-a306-4838a7b813c7" TYPE="ext2"
    Using your favourite editor as root, add an entry to the end of /etc/fstab to auto-mount the RAID array device at the UUID and mount point determined in the previous steps:
    ?
    01
    02
    03
    04
    05
    06
    07
    08
    09
    10
    11
    12
    	
    # /etc/fstab: static file system information.
    #
    # Use 'blkid -o value -s UUID' to print the universally unique identifier
    # for a device; this may be used with UUID= as a more robust way to name
    # devices that works even if disks are added and removed. See fstab(5).
    #
    # <file system> <mount point>   <type>  <options>       <dump>  <pass>
    proc                                      /proc           proc    nodev,noexec,nosuid 0       0
    /dev/mapper/mysolutions-root              /               ext4    errors=remount-ro   0       1
    UUID=849ca1a0-8439-4ba5-b1eb-e74451a07692 /boot           ext2    defaults            0       2
    /dev/mapper/mysolutions-swap_1 none       swap            sw                          0       0
    UUID=d409ca76-9eee-40ea-a306-4838a7b813c7 /media/RAID1_0  ext4    defaults            0       2
    Test your set up by mounting the RAID array device and attempting to create a file:
    ?
    1
    2
    3
    4
    	
    $ sudo mount -a
    $ > /media/RAID1_0/test
    $ ls /media/RAID1_0/
    test

If everything has gone well, you now have a functional RAID 1 array on your system.
Deleting the mdadm RAID Array

If you make a mistake, mdadm is quite forgiving; once you know the proper commands it’s simple to manipulate your RAID array.  To unwind everything back to individual disks with no RAID:

If you’ve added an entry to /etc/fstab, you’ll need to delete that line.

If your RAID array is mounted, you’ll need to unmount it:
?
1
	
$ sudo umount /media/RAID1_0

You’ll also need to stop & remove the RAID array:
?
1
2
	
$ sudo mdadm --stop /dev/md0
$ sudo mdadm --remove /dev/md0

Finally, delete the superblocks from the drives (this is what marks them as being part of a RAID array):
?
1
	
$ sudo mdadm --zero-superblock /dev/sd[ab]
