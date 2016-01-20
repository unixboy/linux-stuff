 
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




