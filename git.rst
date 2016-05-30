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



.netrc

machine github.com
login technoweenie
password SECRET

machine api.github.com
login technoweenie
password SECRET






How to set up an encrypted .netrc file with GPG for GitHub 2FA access

01 Jan 2016

Enabling 2 factor authentication on GitHub is a good way to protect your data, but unfortunately, it means you can’t use your password to login at the command line on Linux for pushes and pulls to HTTPS repositories. You can set up a special .netrc file to enable 2FA login from the command line.
First, go to GitHub and create a Personal Access Token. Then, create a ~/.netrc file with the following contents:

machine github.com
login yourusername
password <token>
protocol https

machine gist.github.com
login yourusername
password <token>
protocol https
where <token> is the token set up on the GitHub website.

Then generate a GPG key if one doesn’t exist:

gpg --gen-key
Make sure to put a passphrase on that key. You may have to do some other tasks on the computer while it generates enough entropy. Then encrypt the ~/.netrc file:

gpg -e -r email@example.com ~/.netrc
Now the ~/.netrc file can be deleted as long as the ~/.netrc.gpg file is kept. Add the netrc credential helper:

curl -o ~/.local/bin/git-credential-netrc https://raw.githubusercontent.com/git/git/master/contrib/credential/netrc/git-credential-netrc
Finally, set up Git to use this file:

git config --global credential.helper "netrc -f ~/.netrc.gpg -v"
Install gpg-agent and pinentry

sudo apt-get install gnupg-agent pinentry-curses
Add to ~/.profile:

# Invoke GnuPG-Agent the first time we login.
# Does `~/.gpg-agent-info' exist and points to gpg-agent process accepting signals?
if test -f $HOME/.gpg-agent-info && \
    kill -0 `cut -d: -f 2 $HOME/.gpg-agent-info` 2>/dev/null; then
    GPG_AGENT_INFO=`cat $HOME/.gpg-agent-info | cut -c 16-`
else
    # No, gpg-agent not available; start gpg-agent
    eval `gpg-agent --daemon --no-grab --write-env-file $HOME/.gpg-agent-info`
fi
export GPG_TTY=`tty`
export GPG_AGENT_INFO
Now https pushes and pulls should work with GitHub on Linux.
