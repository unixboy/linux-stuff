#!/bin/sh

SSHSERV=qa@perf.local
SSHPORT=22
SSHDIR=~/.ssh
SSHDIR_REMOTE=.ssh
TMPDIR=~

#
# function: generate_keys
# descript: Generate RSA/DSA Encryption keys using ssh-keygen
#
function generate_keys
{
    cd $SSHDIR

    # create rsa key for SSHv1
    ssh-keygen -t rsa1

    # create rsa key for SSHv2
    ssh-keygen -t rsa

    # create dsa key for SSHv2
    ssh-keygen -t dsa
}

#
# function: push_keys(dest, port, tmpdir)
# descript: Copy the public keys to a machine whose trust you desire
# param: string hostname:/file destination
# param: int TCP Port#
# param: string Temporary Directory
#
function get_existing_keys
{
    scp -P $SSHPORT $SSHSERV:$SSHDIR_REMOTE/authorized_keys* $TMPDIR/
}

function merge_keys
{
    # copy the public identity and encryption keys to
    # a new 'temporary' file on the local system
    cat $SSHDIR/identity.pub >> $TMPDIR/authorized_keys
    cat $SSHDIR/id_dsa.pub $SSHDIR/id_rsa.pub >> $TMPDIR/authorized_keys2
}

function push_keys
{
    get_existing_keys

    merge_keys

    # set the proper permissions (644) for the authorized_keys file(s)
    chmod 644 $TMPDIR/authorized_keys*

    # copy the authorized_keys file(s) to the remote system
    scp -P $SSHPORT $TMPDIR/authorized_keys* $SSHSERV:$SSHDIR_REMOTE/

    # clean-up local directory
    rm $TMPDIR/authorized_keys*
}

#
# function: verify_deps
# descript: a simple function used to verify the dependencies
#
function verify_deps
{
    if [ ! -x $SSHDIR ]; then
        # mkdir -m 0700 $SSHDIR
        echo ""
        echo "Sorry, but it appears that you have not manually connected to a remote SSH Server yet."
        echo ""
        echo "We will now connect you to $SSHSERV..."
        echo "Please verify that the '~/.ssh' directory does exist on the remote machine. (ls -la | grep ssh;)"
        echo "If the directory does not exist on the remote machine, then you will need to create the directory, and try again. (mkdir -m 0700 ~/.ssh; logout;)"
        echo ""

        ssh $SSHSERV -p $SSHPORT
        exit 0;
    fi
}

function print_help
{
    echo "$0 - An RSA/DSA SSH Key Generator and Distribution Script"
    echo ""
    echo "Generate and Push New RSA/DSA Keys to a remote SSH Server:"
    echo "Usage: $0 [-g|--gen|-all]"
    echo ""
    echo "Push Existing RSA/DSA Keys to a remote SSH Server:"
    echo "Usage: $0 [-p|--push]"
    echo ""
}

case "$1" in
    '-p' | '--push')
        if [ $2 ]; then
            unset SSHSERV
            SSHSERV=$2
        fi
        if [ $3 ]; then
            unset SSHPORT
            SSHPORT=$3
        fi
        if [ $4 ]; then
            unset SSHDIR_REMOTE
            SSHDIR_REMOTE=$4
        fi
        push_keys
    ;;
    '-g' | '--gen' | '-all')
        # verify the dependencies
        verify_deps
        
        generate_keys 
        
        push_keys
        
        echo "Attempting to connect to: $SSHSERV:$SSHPORT..."
        
        sleep 5
        
        ssh $SSHSERV -p $SSHPORT
    ;;
    *)
        print_help
    ;;
esac
