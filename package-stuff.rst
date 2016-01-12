RPM
For RPMs you need two command line utilities, rpm2cpio and cpio. Extracting the contents of the RPM package is a one step process:

::

 rpm2cpio mypackage.rpm | cpio -vid


DEB

DEB files are ar archives, which contain three files:

debian-binary
control.tar.gz
data.tar.gz
As you might have already guessed, the needed archived files exist in data.tar.gz. It is also obvious that unpacking this file is a two-step process.

First, extract the aforementioned three files from the DEB file (ar archive):

::

 ar vx mypackage.deb

Then extract the contents of data.tar.gz using tar:

::

 tar -xzvf data.tar.gz

Or, if you just need to get a listing of the files:

::

 tar -tzvf data.tar.gz

Again the -v option in both ar and tar is used in order to get verbose output. It is safe not to use it. For more information, read the man pages: tar(1) and ar(1).

If anyone knows a one step process to extract the contents of the data.tar.gz, I’d be very interested in it!

Update 1
As Jon suggested in the comment area, the contents of data.tar.gz can be extracted from the DEB package in a one step process as shown below:

::

 ar p mypackage.deb data.tar.gz | tar zx

Update 2 – Debian 8
As Vlad suggested in the comments below, starting with Debian 8, data.tar.gz inside .deb packages has been replaced with data.tar.xz (the xz format, which is based on LZMA2 offers better compression). So, if you are using Debian 8 or newer, the one-liner should be updated to something like this:

::

 ar p mypackage.deb data.tar.xz | unxz | tar x

Moreover, as cspenceiv suggested in the comments below, tar is now able to handle xz compression and decompression (I also confirm tar supports this compression filter on CentOS), so the following one liner would do the trick as well:

::

 ar p mypackage.deb data.tar.xz | tar xJ

That will do it.
