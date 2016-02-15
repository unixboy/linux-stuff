#!/bin/bash
# say: ./pussh.sh hostname
# Uploads your id_rsa.pub to the specified host, wrapped for readability
if [ ! -r ${HOME}/.ssh/id_rsa.pub ]; then
 ssh-keygen -b 2048 -t rsa
fi
# Append to the copy on the remote server
cat ~/.ssh/id_rsa.pub | ssh ${USER}@$1 "cat - >> .ssh/authorized_keys"

if [ $? -eq 0 ]; then
  echo "Success"
fi
