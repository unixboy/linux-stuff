du -sh is a good place to start. The options are (from man du):

   -s, --summarize
          display only a total for each argument

   -h, --human-readable
          print sizes in human readable format (e.g., 1K 234M 2G)
To check more than one directory and see the total, use du -sch:

   -c, --total
          produce a grand total
          
          
          
          Just use the du command:

du -sh *
will give you the size of all the directories,files etc in current directory in human readable format.

You can use the df command to know the free space in the disk:

df -h .

If you just want do know the total size of a directory then jump into it and run:

du -hs
If you also would like to know which sub-folders spend how much disk space?! You could extend this command to:

du -h --max-depth=1 | sort -hr
which will give you the size of all sub-folders (level 1). The output will be sorted (largest folder on top).




 

sudo ls -1d */ | sudo xargs -I{} du {} -sh && sudo du -sh


If you want to know the actual file sizes, add the -b option to du.

du -csbh .

df -h .; du -sh -- * | sort -hr
This shows how much disk space you have left on the current drive and then tells you how much every file/directory takes up.

