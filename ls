You will see largest file first before sorting the operands in lexicographical order. The following command will sort file size in reverse order:
$ ls -l -S | sort -k 5 -n

OR try  
$ ls -lSr

Sort output and print sizes in human readable format (e.g., 1K 234M 2G)

Pass the -h option to the ls command as follows:
$ ls -lSh
$ ls -l -S -h *.avi
$ ls -l -S -h ~/Downloads/*.mp4 | more

Force sort by size option

You need to pass the -S or --sort=size option as follows:
$ ls -S
$ ls -S -l
$ ls --sort=size -l
$ ls --sort=size *.avi
$ ls -S -l *.avi


