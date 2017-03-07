#!/usr/bin/env bash

echo "Beginning to remove Deployments."
echo

for file in $(cat builds.txt); do
   echo "Now removing the Deployments $file..."
   azure group delete --name "$file" --quiet
   azure storage container delete "$file" --quiet

done

echo
echo "Finished removing Builds."
exit
