 
::

 du --separate-dirs -h . |sort -h

::
 
 du -ch | sort -h

::

 durep -td 4 -hs 50M /usr/

::
 
 find . -type d -execdir du -ch "{}" \;

::

 du -h | perl -ne '$n=()=$_=~m#/#g;  print unless $n > 2'

::

 du -h | perl -ne 'print unless ($n=()=$_=~m#/#g) > 2 '

::

 sudo apt-get install pydf
 
::

 $ pydf  
 Filesystem  Size  Used Avail Use%                 Mounted on
 /dev/sda2  2719G  238G 2342G  8.8 [#............] /         
 /dev/sda1   512M 3456k  509M  0.7 [.............] /boot/efi 
 /dev/sdb   2751G 2340G  271G 85.1 [###########..] /home/

 
 
 


