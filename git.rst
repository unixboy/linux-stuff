Diagnosis
To turn on Git debug logging, before pushing using the command line, proceed like that for different OS:
On Linux
Execute the following in the command line before executing the Git command:

::

 export GIT_TRACE_PACKET=1
 export GIT_TRACE=1
 export GIT_CURL_VERBOSE=1

On Windows
Execute the following in the command line before executing the Git command:


::
 
 set GIT_TRACE_PACKET=1
 set GIT_TRACE=1
 set GIT_CURL_VERBOSE=1


